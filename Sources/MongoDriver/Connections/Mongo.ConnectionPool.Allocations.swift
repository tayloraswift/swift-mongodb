import MongoIO
import NIOCore

extension Mongo.ConnectionPool
{
    /// Categorizes and tracks channels by their observed health and
    /// allocation status.
    struct Allocations
    {
        /// Connections that are currently free to be allocated,
        /// and are believed to be healthy.
        private
        var released:[UInt: any Channel]
        /// Connections that are currently allocated and are
        /// believed to be healthy.
        private
        var retained:[UInt: any Channel]
        /// Connections that are currently allocated but are *not*
        /// believed to be healthy.
        /// Does not contribute to the total connection ``count``.
        private
        var perished:Set<UInt>

        /// Additional channels that have no other way of being
        /// represented in this structure. Contributes to the total
        /// connection ``count``.
        private
        var pending:Int

        private
        var observers:Mongo.Observers
        /// All requests currently awaiting connections, identified by `UInt`.
        private
        var requests:[UInt: CheckedContinuation<Mongo.ConnectionPool.Allocation, any Error>]
        /// The current stage of the pool’s lifecycle. Pools start out in the
        /// “connecting” state, and eventually transition to the “draining” state,
        /// which is terminal. There are no “in-between” states.
        ///
        /// The implementation does not lint idle connections, so the connection
        /// count can only decrease during the connecting stage if individual
        /// connections perish.
        private(set)
        var phase:Phase

        /// Monotonically-increasing counters used to generate request
        /// and connection identifiers.
        private
        var counter:(connection:UInt, request:UInt)

        init(connector:Mongo.Connector<Mongo.Authenticator>)
        {
            self.released = [:]
            self.retained = [:]
            self.perished = []
            self.pending = 0

            self.observers = .none
            self.requests = [:]
            self.phase = .connecting(connector)

            self.counter = (0, 0)
        }
    }
}
extension Mongo.ConnectionPool.Allocations
{
    mutating
    func whenEmpty(resume observer:CheckedContinuation<Void, Never>)
    {
        if case .draining = self.phase, self.isEmpty
        {
            observer.resume()
        }
        else
        {
            self.observers.append(observer)
        }
    }
    /// Checks that this structure is safe to deinitialize.
    func destroy()
    {
        guard self.requests.isEmpty
        else
        {
            fatalError("unreachable (deinitialized connection pool while continuations are awaiting!)")
        }
        guard self.isEmpty
        else
        {
            fatalError("unreachable (deinitialized connection pool while pool contains connections!)")
        }
        guard case .draining = self.phase
        else
        {
            fatalError("unreachable (deinitialized connection pool that has not been drained!)")
        }
    }
}

extension Mongo.ConnectionPool.Allocations
{
    /// Mints a new connection identifier.
    private mutating
    func connection() -> UInt
    {
        self.counter.connection += 1
        return self.counter.connection
    }
    /// Mints a new request identifier.
    private mutating
    func request() -> UInt
    {
        self.counter.request += 1
        return self.counter.request
    }
}
extension Mongo.ConnectionPool.Allocations
{
    mutating
    func submit(request:UInt,
        resuming continuation:CheckedContinuation<Mongo.ConnectionPool.Allocation, any Error>)
    {
        self.requests.updateValue(continuation, forKey: request)
    }
    /// Unblocks an awaiting request with the given channel, if one exists.
    ///
    /// -   Returns:
    ///     [`true`]() if there was a request that was unblocked by this call,
    ///     [`false`]() otherwise.
    mutating
    func yield(_ allocation:Mongo.ConnectionPool.Allocation) -> Bool
    {
        switch self.requests.popFirst()?.value.resume(returning: allocation)
        {
        case nil: false
        case ()?: true
        }
    }
    mutating
    func fail(request:UInt, throwing error:any Error)
    {
        self.requests.removeValue(forKey: request)?.resume(throwing: error)
    }
}

extension Mongo.ConnectionPool.Allocations
{
    /// Marks the allocation released in this table, or hands it off
    /// directly to an awaiting request, if at least one such request
    /// exists. If the allocation was marked perished by a racing call
    /// to ``replace(_:releasing:settings:)``, the allocation table
    /// won’t do anything except forget about the allocation ID.
    mutating
    func reindex(_ allocation:__owned Mongo.ConnectionPool.Allocation)
    {
        if case  _? = self.perished.remove(allocation.id)
        {
            //  Channel was healthy at the time the caller released it,
            //  but perished before we could reindex it.
            return
        }
        if self.yield(allocation)
        {
            //  Directly handed off channel to another request.
            return
        }

        guard   let channel:any Channel = self.retained.removeValue(
                    forKey: allocation.id)
        else
        {
            fatalError("unreachable (reindexing unknown allocation id!)")
        }
        guard   case nil = self.released.updateValue(allocation.channel,
                    forKey: allocation.id),
                channel === allocation.channel
        else
        {
            fatalError("unreachable (reindexing colliding allocation id!)")
        }
    }
    /// Drops the allocation from this table, resuming any ``observers``
    /// if dropping the allocation emptied the table. If the allocation
    /// was marked perished by a racing call to
    /// ``replace(_:releasing:settings:)``, the allocation table won’t
    /// do anything except forget about the allocation ID.
    mutating
    func deindex(_ id:UInt)
    {
        if      case _? = self.perished.remove(id)
        {
            return
        }
        else if case _? = self.retained.removeValue(forKey: id)
        {
            if  case .draining = self.phase, self.isEmpty
            {
                self.observers.resume()
            }
        }
        else
        {
            fatalError("unreachable (removed a channel more than once!)")
        }
    }
}

extension Mongo.ConnectionPool.Allocations
{
    mutating
    func next(releasing:Int,
        settings:Mongo.ConnectionPoolSettings) -> Mongo.ConnectionPool.AllocationResult
    {
        switch self.phase
        {
        case .connecting(let connector):
            if  let allocation:Mongo.ConnectionPool.Allocation = self.next()
            {
                return .available(allocation)
            }
            if  self.requests.count >= releasing,
                self.pending < settings.rate,
                self.count < settings.size.upperBound
            {
                return .reserved(self.reserve(connector: connector))
            }
            else
            {
                return .blocked(self.request())
            }

        case .draining(let error):
            return .failure(error)
        }
    }
    /// Pops a channel from the set of released channels, if one is
    /// available, and transfers it to the set of retained channels.
    /// Returns an allocation wrapping the channel, if it exists.
    ///
    /// Does not affect the allocation count.
    ///
    /// Traps if the transfer could not be performed.
    private mutating
    func next() -> Mongo.ConnectionPool.Allocation?
    {
        guard let (id, channel):(UInt, any Channel) = self.released.popFirst()
        else
        {
            return nil
        }
        if case nil = self.retained.updateValue(channel, forKey: id)
        {
            return .init(channel: channel, id: id)
        }
        else
        {
            fatalError("unreachable (checked out a channel more than once!)")
        }
    }
}
extension Mongo.ConnectionPool.Allocations
{
    /// Indicates if the pool should expand.
    func expandable(releasing:Int,
        settings:Mongo.ConnectionPoolSettings) -> Bool
    {
        self.count < settings.size.lowerBound ||
        self.count < settings.size.upperBound &&
            releasing + self.released.count < self.requests.count
    }

    /// The number of non-perished connections, including pending connections,
    /// currently known to this structure.
    var count:Int
    {
        self.pending + self.released.count + self.retained.count
    }

    /// Indicates if the structure is devoid of non-perished connections,
    /// including pending connections.
    private
    var isEmpty:Bool
    {
        self.released.isEmpty &&
        self.retained.isEmpty &&
        self.pending == 0
    }
}

extension Mongo.ConnectionPool.Allocations
{
    mutating
    func replace(_ id:UInt,
        releasing:Int,
        settings:Mongo.ConnectionPoolSettings) -> Mongo.ConnectionPool.Reservation?
    {
        if      case _? = self.released.removeValue(forKey: id)
        {
            //  Nobody is holding the allocation, so we can just forget about it.
        }
        else if case _? = self.retained.removeValue(forKey: id)
        {
            //  Won the race with ``deindex(_:)``. Add the allocation ID to the
            //  set of perished channels, so that ``deindex(_:)`` doesn’t freak out.
            guard   case nil = self.perished.update(with: id)
            else
            {
                fatalError("unreachable (perished a channel more than once!)")
            }
        }
        else
        {
            //  Lost the race with ``deindex(_:)``, so we can just forget about
            //  the allocation.
        }

        switch self.phase
        {
        case .connecting(let connector):
            return self.reserve(connector: connector, releasing: releasing, settings: settings)

        case .draining:
            if  self.isEmpty
            {
                self.observers.resume()
            }
            return nil
        }
    }
    mutating
    func reserve(releasing:Int,
        settings:Mongo.ConnectionPoolSettings) -> Mongo.ConnectionPool.Reservation?
    {
        switch self.phase
        {
        case .connecting(let connector):
            self.reserve(connector: connector, releasing: releasing, settings: settings)

        case .draining:
            nil
        }
    }
    private mutating
    func reserve(connector:Mongo.Connector<Mongo.Authenticator>,
        releasing:Int,
        settings:Mongo.ConnectionPoolSettings) -> Mongo.ConnectionPool.Reservation?
    {
        if  self.pending < settings.rate,
            self.expandable(releasing: releasing, settings: settings)
        {
            self.reserve(connector: connector)
        }
        else
        {
            nil
        }
    }
    private mutating
    func reserve(
        connector:Mongo.Connector<Mongo.Authenticator>) -> Mongo.ConnectionPool.Reservation
    {
        self.pending += 1
        return .init(connector: connector, id: self.connection())
    }
}
extension Mongo.ConnectionPool.Allocations
{
    mutating
    func fill(with allocation:__owned Mongo.ConnectionPool.Allocation)
    {
        self.pending -= 1

        if  self.yield(allocation)
        {
            //  allocation was given to an already-awaiting request.
            if case nil = self.retained.updateValue(allocation.channel, forKey: allocation.id)
            {
                return
            }
        }
        else
        {
            if case nil = self.released.updateValue(allocation.channel, forKey: allocation.id)
            {
                return
            }
        }

        fatalError("unreachable (inserted a channel more than once!)")
    }
    mutating
    func erase()
    {
        self.pending -= 1

        if  case .draining = self.phase, self.isEmpty
        {
            self.observers.resume()
        }
    }

    mutating
    func drain(throwing error:Mongo.ConnectionPoolDrainedError, erase:Bool = false)
    {
        if erase
        {
            self.pending -= 1
        }

        switch self.phase
        {
        case .connecting:
            self.phase = .draining(error)

            for request:CheckedContinuation<Mongo.ConnectionPool.Allocation, any Error>
                in self.requests.values
            {
                request.resume(throwing: error)
            }
            self.requests = [:]

            if  self.isEmpty
            {
                self.observers.resume()
            }
            else
            {
                self.crosscancel(throwing: error)
            }

        case .draining:
            if  self.isEmpty
            {
                self.observers.resume()
            }
        }
    }

    private
    func crosscancel(throwing error:Mongo.ConnectionPoolDrainedError)
    {
        for channel:any Channel in [self.retained.values, self.released.values].joined()
        {
            channel.writeAndFlush(Mongo.WireAction.cancel(throwing: Mongo.NetworkError.init(
                    underlying: error,
                    provenance: .crosscancellation)),
                promise: nil)
        }
    }
}
