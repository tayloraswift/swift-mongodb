import MongoIO
import NIOCore

extension Mongo.ConnectionPool
{
    struct Reservation
    {
        private
        let connector:Mongo.Connector<Mongo.Authenticator>
        let id:UInt

        init(connector:Mongo.Connector<Mongo.Authenticator>, id:UInt)
        {
            self.connector = connector
            self.id = id
        }
    }
}
extension Mongo.ConnectionPool.Reservation
{
    func connect() async throws -> Mongo.UnsafeConnection
    {
        try await self.connector.connect(id: self.id)
    }
}
extension Mongo.ConnectionPool
{
    enum CheckoutResult
    {
        case available(Mongo.UnsafeConnection)
        case reserved(Reservation)
        case blocked(UInt)
        case failure(Mongo.ConnectionPoolDrainedError)
    }
}
extension Mongo.ConnectionPool
{
    enum Observers
    {
        case none
        case one(CheckedContinuation<Void, Never>)
        case many([CheckedContinuation<Void, Never>])
    }
}
extension Mongo.ConnectionPool.Observers
{
    mutating
    func append(_ observer:CheckedContinuation<Void, Never>)
    {
        switch self
        {
        case .none:
            self = .one(observer)
        case .one(let first):
            self = .many([first, observer])
        case .many(var list):
            self = .none
            list.append(observer)
            self = .many(list)
        }
    }
    mutating
    func resume()
    {
        defer
        {
            self = .none
        }
        switch self
        {
        case .none:
            return
        case .one(let observer):
            observer.resume()
        case .many(let observers):
            for observer:CheckedContinuation<Void, Never> in observers
            {
                observer.resume()
            }
        }
    }
}
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
        var observers:Observers
        /// All requests currently awaiting connections, identified by `UInt`.
        private
        var requests:[UInt: CheckedContinuation<Mongo.UnsafeConnection, any Error>]
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
            self.observers.resume()
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
        resuming continuation:CheckedContinuation<Mongo.UnsafeConnection, any Error>)
    {
        self.requests.updateValue(continuation, forKey: request)
    }
    /// Unblocks an awaiting request with the given channel, if one exists.
    ///
    /// -   Returns:
    ///     [`true`]() if there was a request that was unblocked by this call,
    ///     [`false`]() otherwise.
    mutating
    func yield(_ allocation:Mongo.UnsafeConnection) -> Bool
    {
        switch self.requests.popFirst()?.value.resume(returning: allocation)
        {
        case nil: return false
        case ()?: return true
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
    mutating
    func reindex(_ allocation:__owned Mongo.UnsafeConnection)
    {
        if self.yield(allocation)
        {
        }
        else if case  _? = self.perished.remove(allocation.id)
        {
        }
        else if case  _? = self.retained.removeValue(
                    forKey: allocation.id),
                case nil = self.released.updateValue(allocation.channel, 
                    forKey: allocation.id)
        {
        }
        else
        {
            fatalError("unreachable (checked in a channel more than once!)")
        }
    }
    mutating
    func deindex(_ id:UInt)
    {
        if      case _? = self.retained.removeValue(forKey: id)
        {
        }
        else if case _? = self.perished.remove(id)
        {
        }
        else
        {
            fatalError("unreachable (removed a channel more than once!)")
        }

        if  case .draining = self.phase, self.isEmpty
        {
            self.observers.resume()
        }
    }
}

extension Mongo.ConnectionPool.Allocations
{
    mutating
    func next(releasing:Int,
        settings:Mongo.ConnectionPool.Settings) -> Mongo.ConnectionPool.CheckoutResult
    {
        switch self.phase
        {
        case .connecting(let connector):
            if  let allocation:Mongo.UnsafeConnection = self.next()
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
    /// Returns a reference to the channel, if it exists.
    ///
    /// Does not affect the connection count.
    ///
    /// Traps if the transfer could not be performed.
    private mutating
    func next() -> Mongo.UnsafeConnection?
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
        settings:Mongo.ConnectionPool.Settings) -> Bool
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
        settings:Mongo.ConnectionPool.Settings) -> Mongo.ConnectionPool.Reservation?
    {
        if      case nil = self.released.removeValue(forKey: id)
        {
        }
        else if case  _? = self.retained.removeValue(forKey: id)
        {
            //  lost the race with ``remove(_:)``
        }

        guard   case nil = self.perished.update(with: id)
        else
        {
            fatalError("unreachable (perished a channel more than once!)")
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
        settings:Mongo.ConnectionPool.Settings) -> Mongo.ConnectionPool.Reservation?
    {
        switch self.phase
        {
        case .connecting(let connector):
            return self.reserve(connector: connector, releasing: releasing, settings: settings)
        
        case .draining:
            return nil
        }
    }
    private mutating
    func reserve(connector:Mongo.Connector<Mongo.Authenticator>,
        releasing:Int,
        settings:Mongo.ConnectionPool.Settings) -> Mongo.ConnectionPool.Reservation?
    {
        if  self.pending < settings.rate,
            self.expandable(releasing: releasing, settings: settings)
        {
            return self.reserve(connector: connector)
        }
        else
        {
            return nil
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
    func fill(with allocation:__owned Mongo.UnsafeConnection)
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

            for request:CheckedContinuation<Mongo.UnsafeConnection, any Error>
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
            channel.writeAndFlush(MongoIO.Action.cancel(throwing: .crosscancelled(error)),
                promise: nil)
        }
    }
}
