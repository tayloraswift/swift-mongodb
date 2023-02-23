import Atomics
import BSON
import Durations
import Durations_Atomics
import Heartbeats
import MongoChannel
import MongoMonitoring

//  these are extensions on the ``MongoMonitoringDelegate`` so they
//  only appear as public API if you import that module explicitly.
extension MongoMonitoringDelegate where Self == Mongo.ConnectionPool
{
    public nonisolated
    func requestRecheck()
    {
        self.heart.beat()
    }
    public nonisolated
    func stopMonitoring()
    {
        self.heart.stop()
    }
}
extension Mongo.ConnectionPool:MongoMonitoringDelegate
{
}

extension Mongo
{
    /// A thread-safe reference type that maintains connections to a particular
    /// `mongod` or `mongos` host, services connection requests, and serves
    /// as a delegate for a server monitoring task.
    ///
    /// Create (or await) a connection with ``create(by:)``. Destroy a connection
    /// with ``destroy(_:)``, which returns it to the pool and (possibly) makes
    /// it available to other tasks.
    ///
    /// Typically, a monitoring task will create a connection pool alongside a
    /// monitoring channel, and align its lifetime with the lifetime of the
    /// monitoring channel. If the monitoring channel collapses, the pool will
    /// be drained, and a new one may be created to replace it.
    public final
    actor ConnectionPool
    {
        /// The generation number of this connection pool. The pool attaches this
        /// token to every connection created from it.
        nonisolated
        let generation:UInt
        /// The size and width of this connection pool.
        nonisolated
        let parameters:Parameters
        /// The connection timeout used internally by the pool to create connections.
        /// The service monitor also uses this to compute deadlines for server
        /// monitoring operations.
        nonisolated
        let timeout:ConnectionTimeout
        
        /// The heartbeat controller for the monitoring task that created this pool.
        nonisolated
        let heart:Heart
        /// The host this pool creates connections to.
        nonisolated
        let host:Host

        private nonisolated
        let logger:Logger?
        
        /// The connections stored in this pool.
        private
        var connections:Connections
        private nonisolated
        let releasing:UnsafeAtomic<Int>
        /// All requests currently awaiting connections, identified by `UInt`.
        private
        var requests:[UInt: CheckedContinuation<ConnectionAllocation, any Error>]

        private nonisolated
        let latency:UnsafeAtomic<Nanoseconds>

        /// The error that will be reported if a connection cannot be created.
        /// This is initially a ``ConnectionCheckoutError``.
        private
        var error:any Error
        /// The current stage of the pool’s lifecycle. Pools start out in the
        /// “filling” state, and eventually transition to the “draining” state,
        /// which is terminal. There are no “in-between” states.
        ///
        /// The implementation does not lint idle connections, so the connection
        /// count can only decrease during the filling stage if individual
        /// connections perish.
        private
        var state:State
        /// Monotonically-increasing counters used to generate request
        /// and connection identifiers.
        private
        var next:Counters

        /// Avoid setting the maximum pool size to a very large number, because
        /// the pool makes no linting guarantees.
        init(generation:UInt,
            signaling heart:Heart,
            connector:MonitorConnector,
            timeout:ConnectionTimeout,
            logger:Logger?,
            host:Host)
        {
            self.generation = generation
            self.parameters = connector.pool
            self.timeout = timeout
            self.heart = heart
            self.host = host

            self.logger = logger

            self.connections = .init()
            self.releasing = .create(0)
            self.requests = [:]

            self.latency = .create(0)

            self.error = ConnectionCheckoutError.init()
            self.state = .filling(.init(bootstrap: connector.parameters.bootstrap(for: host),
                credentials: connector.credentials,
                cache: connector.credentialCache,
                host: host))
            self.next = .init()

            let _:Task<Void, Never> = .init
            {
                await self.fill()
            }

            self.log(.creating(self.parameters))
        }
        deinit
        {
            self.releasing.destroy()
            self.latency.destroy()

            guard self.requests.isEmpty
            else
            {
                fatalError("unreachable (deinitialized connection pool while continuations are awaiting!)")
            }
            guard self.connections.isEmpty
            else
            {
                fatalError("unreachable (deinitialized connection pool while pool contains connections!)")
            }
            guard case .draining(nil) = self.state
            else
            {
                fatalError("unreachable (deinitialized connection pool that has not been drained!)")
            }
        }
    }
}
extension Mongo.ConnectionPool
{
    /// The number of non-perished connections, including pending connections,
    /// currently in the pool.
    ///
    /// Connection count is regulated by the pool’s ``Parameters size`` and
    /// ``Parameters rate`` parameters.
    public
    var count:Int
    {
        self.connections.count
    }

    /// The number of connections this pool is currently capable of providing
    /// without needing to establish new connections. This is defined as the
    /// number of currently available connections plus the number of connections
    /// that have been returned to the pool’s actor loop, but have not yet been
    /// re-indexed by this pool.
    private
    var unallocated:Int
    {
        self.connections.available + self.releasing.load(ordering: .relaxed)
    }
}
extension Mongo.ConnectionPool
{
    /// Sets the round-trip latency tracked by this pool.
    public nonisolated
    func set(latency:Nanoseconds)
    {
        self.latency.store(latency, ordering: .relaxed)
    }
    /// Adjusts the given deadline to account for round-trip latency, as
    /// tracked by this pool.
    public nonisolated
    func adjust(deadline:ContinuousClock.Instant) -> ContinuousClock.Instant
    {
        deadline - .nanoseconds(self.latency.load(ordering: .relaxed))
    }
}
extension Mongo.ConnectionPool
{
    /// Unblocks an awaiting request with the given channel, if one exists.
    ///
    /// -   Returns:
    ///     [`true`]() if there was a request that was unblocked by this call,
    ///     [`false`]() otherwise.
    private
    func yield(_ allocation:Mongo.ConnectionAllocation) -> Bool
    {
        if case ()? = self.requests.popFirst()?.value.resume(returning: allocation)
        {
            return true
        }
        else
        {
            return false
        }
    }
    /// Sleeps until the specified deadline, then fails the specified connection
    /// request if it is still awaiting. It is expected that the duration of this
    /// call will be shortened via task cancellation if the request succeeds
    /// before the deadline.
    private
    func fail(_ request:UInt, by deadline:Mongo.ConnectionDeadline) async throws
    {
        //  will throw ``CancellationError`` if request succeeds
        try await Task.sleep(until: deadline.instant, clock: .continuous)
        if  let continuation:CheckedContinuation<Mongo.ConnectionAllocation, any Error> =
                self.requests.removeValue(forKey: request)
        {
            continuation.resume(throwing: Mongo.ConnectionCheckoutError.init())
        }
    }

    private nonisolated
    func log(_ event:Event)
    {
        self.logger?.yield(level: .full, event: .pool(host: self.host,
            generation: self.generation,
            event: event))
    }
}
extension Mongo.ConnectionPool
{
    /// Transitions the pool to its draining state (if it is not already in that
    /// state), unblocks all awaiting connection requests, closes all unallocated
    /// connections, interrupts all (non-perished) allocated connections, and waits
    /// for all allocated connections to be returned to the pool via ``destroy(_:)``.
    ///
    /// The pool will only directly close and await unallocated connections. It is
    /// the responsibility of tasks that hold connections to destroy them so that
    /// a call to this method can unblock.
    ///
    /// No interrupt signal will be sent to perished connections, since their
    /// channels are already closed.
    func drain(because error:Mongo.MonitorRemovedError) async
    {
        defer
        {
            self.log(.drained)
        }
        if case .draining(_?) = self.state
        {
            fatalError("unreachable (draining connection pool that is already being drained!)")
        }

        for request:CheckedContinuation<Mongo.ConnectionAllocation, any Error>
            in self.requests.values
        {
            request.resume(throwing: error)
        }
        self.requests = [:]

        //  move channels that we can directly close
        //  (as opposed to waiting for a client to release them)
        let released:[MongoChannel] = self.connections.shrink()
        
        //  this check is needed because we can only succeed the continuation
        //  when total channel count crosses from 1 to 0. so if the inventory
        //  is already empty, we won’t observe a cross-over.
        if  self.connections.isEmpty
        {
            self.state = .draining(nil)
            await released.close()
            return
        }

        async
        let direct:Void = released.close()
        await withCheckedContinuation
        {
            self.state = .draining($0)
            self.connections.interrupt()
        }
        await direct
    }

    /// Transitions the pool to its draining state (if it is not already in that
    /// state), sends an interrupt signal to its associated monitoring task, and
    /// unblocks all awaiting connection requests by throwing them the given error.
    /// The error will also be stored in ``error``, so that new connection
    /// requests can also observe it.
    ///
    /// If the pool is already in a draining state and a caller is waiting on
    /// the drainage to complete, this method checks if the pool is empty and
    /// unblocks the awaiter accordingly. (This allows us to use this method as an
    /// epilogue to a failed ``expand(using:)`` call.)
    private
    func close(because error:any Error)
    {
        defer
        {
            self.log(.draining)
        }
        switch self.state
        {
        case .filling:
            self.stopMonitoring()
            self.error = error
            for request:CheckedContinuation<Mongo.ConnectionAllocation, any Error>
                in self.requests.values
            {
                request.resume(throwing: error)
            }
            self.requests = [:]
            self.state = .draining(nil)
        
        case .draining(nil):
            break
        
        case .draining(let continuation?):
            if  self.connections.isEmpty
            {
                continuation.resume()
                self.state = .draining(nil)
            }
        }
    }
}
extension Mongo.ConnectionPool
{
    /// Returns an existing allocation in the pool if one is available, creating
    /// it if the pool has capacity for additional connections. Otherwise, blocks
    /// until one of those conditions is met, or the specified deadline passes.
    ///
    /// The deadline is not enforced if a connection is already available in the
    /// pool when the actor services the request.
    ///
    /// If the deadline passes while the pool is creating a connection for the
    /// caller, the call will return [`nil`](), but the allocation will still be
    /// created and added to the pool, and may be used to complete a different
    /// request.
    func create(by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.ConnectionAllocation
    {
        while case .filling(let connector) = self.state
        {
            if  let allocation:Mongo.ConnectionAllocation = self.connections.checkout()
            {
                return allocation
            }
            if  self.connections.pending < self.parameters.rate,
                self.connections.count < self.parameters.size.upperBound,
                self.releasing.load(ordering: .relaxed) <= self.requests.count
            {
                // note: this checks for awaiting requests, and may use the
                // newly-established connection to succeed a different request.
                // so it is not guaranteed that the next iteration of the loop
                // will yield a channel.
                await self.expand(using: connector)
            }
            else
            {
                let request:UInt = self.next.request()

                #if compiler(<5.8)
                async
                let __:Void = self.fail(request, by: deadline)
                #else
                async
                let _:Void = self.fail(request, by: deadline)
                #endif

                return try await withCheckedThrowingContinuation
                {
                    self.requests.updateValue($0, forKey: request)
                }
            }
        }

        throw self.error
    }
    /// Synchronously notifies the pool that a connection is being returned
    /// to it, and asynchronously re-indexes the connection.
    ///
    /// -   Parameters:
    ///     -   channel:
    ///         The channel to release, which must have been created by this
    ///         pool.
    ///     -   reuse:
    ///         Indicates if the connection should be reused.
    ///         If [`false`](), the channel will be asynchronously closed and
    ///         removed from the pool.
    ///
    /// Every *successful* call to ``create(by:)`` must be paired with a call
    /// to `destroy(_:reuse:)`.
    ///
    /// If `reuse` is [`true`](), later calls to ``create(by:)`` will wait for
    /// the destroyed connection to be re-indexed, instead of establishing a new
    /// one, provided that there are more un-indexed connections than
    /// currently-blocked requests.
    ///
    /// If `reuse` is [`false`](), this method does not replace the connection,
    /// because replacement is performed when the underlying channel closes,
    /// which may take place before the wrapping connection is destroyed. 
    nonisolated
    func destroy(_ allocation:Mongo.ConnectionAllocation, reuse:Bool)
    {
        if  reuse
        {
            self.releasing.wrappingIncrement(ordering: .relaxed)
        }
        let _:Task<Void, Never> = .init
        {
            await self.destroy(allocation, reindex: reuse)
        }
    }
    private
    func destroy(_ allocation:Mongo.ConnectionAllocation, reindex:Bool) async
    {
        if  reindex
        {
            self.releasing.wrappingDecrement(ordering: .relaxed)
        }
        switch self.state
        {
        case .filling:
            guard reindex
            else
            {
                await allocation.channel.close()
                self.connections.remove(allocation)
                // pool lifecycle stage may have changed
                break
            }
            if  self.yield(allocation)
            {
                // channel was handed-off directly to the next request
                return
            }
            else
            {
                self.connections.checkin(allocation)
                return
            }
        
        case .draining:
            //  we have to wait for the channel to close before removing
            //  it from the retained list, because a re-entrant call to this
            //  method might observe `self.count == 0` while the channel is
            //  still open.
            await allocation.channel.close()
            self.connections.remove(allocation)
        }

        if  self.connections.isEmpty,
            case .draining(let continuation?) = self.state
        {
            continuation.resume()
            self.state = .draining(nil)
        }
    }
    /// Marks the given channel as “perished”, and replaces it (by dispatching
    /// to ``fill(using:)``) if the pool is in its filling stage.
    /// If the pool is in the draining stage, and perishing the channel reduced
    /// the connection count to zero, calling this method may unblock a call to
    /// ``drain``.
    private
    func replace(perished allocation:Mongo.ConnectionAllocation) async
    {
        self.connections.perish(allocation)
        switch self.state
        {
        case .filling(let connector):
            await self.fill(using: connector)
        
        case .draining(let continuation?):
            if  self.connections.isEmpty
            {
                continuation.resume()
                self.state = .draining(nil)
            }
        
        case .draining(nil):
            break
        }
    }
    /// Checks if the pool is (still) in its filling stage and calls
    /// ``fill(using:)`` if so. Does nothing if the pool is draining.
    private
    func fill() async
    {
        if  case .filling(let connector) = self.state
        {
            await self.fill(using: connector)
        }
    }
    /// Dispatches to ``expand(using:)``, but only if the pool ought to be
    /// establishing new connections, based on the current connection count,
    /// the number of connections already being established, and the number of
    /// blocked requests.
    ///
    /// This method must only be called while the pool is in the filling stage.
    /// The ``Mongo/Connection/Bootstrap`` type is not ``Sendable``, which
    /// should prevent some of the more-common reentrancy mistakes.
    private
    func fill(using connector:Mongo.Connector) async
    {
        guard   self.connections.pending < self.parameters.rate
        else
        {
            return
        }
        if      self.connections.count < self.parameters.size.lowerBound
        {
            await self.expand(using: connector)
        }
        else if self.connections.count < self.parameters.size.upperBound,
                self.unallocated < self.requests.count
        {
            await self.expand(using: connector)
        }
    }
    /// Tries to create and add a new connection to the pool. If anything goes wrong
    /// during this process, the pool will be closed with ``close(because:)``.
    ///
    /// If the pool is still in the filling stage when the connection is successfully
    /// established, it will trigger a (non-blocking) recursive call to this method
    /// via ``fill``. Because the call to ``fill`` is non-blocking, it is possible
    /// that no recursive call actually takes place, because a concurrent `expand(using:)`
    /// call may have already brought the pool back to a healthy size in the meantime.
    ///
    /// If the pool transitions to the draining stage while the connection is being
    /// created, the connection will be closed and the connection count decremented.
    /// Because a pending connection still contributes to connection count, this may
    /// unblock a call to ``drain``.
    private
    func expand(using connector:Mongo.Connector) async
    {
        do
        {
            let deadline:Mongo.ConnectionDeadline = self.timeout.deadline(
                from: .now)

            let connection:UInt = self.next.connection()

            self.connections.pending += 1
            self.log(.expanding(id: connection))

            let allocation:Mongo.ConnectionAllocation = .init(
                channel: try await connector.channel(to: self.host, by: deadline),
                id: connection)

            switch self.state
            {
            case .filling:
                allocation.channel.whenClosed
                {
                    self.log(.perished(id: connection, because: $0))

                    let _:Task<Void, Never> = .init
                    {
                        await self.replace(perished: allocation)
                    }
                }

                self.connections.pending -= 1
                self.log(.expanded(id: connection))

                if  self.yield(allocation)
                {
                    //  allocation was given to an already-awaiting request.
                    self.connections.insert(retained: allocation)
                }
                else
                {
                    self.connections.insert(released: allocation)
                }

                if  self.connections.count < self.parameters.size.lowerBound ||
                    self.connections.count < self.parameters.size.upperBound &&
                    self.unallocated < self.requests.count
                {
                    let _:Task<Void, Never> = .init
                    {
                        //  re-checks preconditions, since it may have been a while
                        //  since this task was initiated.
                        await self.fill()
                    }
                }

                return
            
            case .draining:
                await allocation.channel.close()
                self.connections.pending -= 1
            }

            if  self.connections.isEmpty,
                case .draining(let continuation?) = self.state
            {
                continuation.resume()
                self.state = .draining(nil)
            }
        }
        catch let error
        {
            self.connections.pending -= 1
            self.close(because: error)
        }
    }
}
