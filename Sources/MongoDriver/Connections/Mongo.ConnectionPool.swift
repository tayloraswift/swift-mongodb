import BSON
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
    public nonisolated
    func stopMonitoring(throwing error:any Error)
    {
        self.heart.stop(throwing: error)
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
    /// it available to other tasks. The pool expects *all* connections to be
    /// eventually destroyed, even if the underlying channel errors or closes.
    /// A call to ``drain`` will not unblock until every connection created by
    /// that pool has been destroyed.
    ///
    /// Typically, a monitoring task will create a connection pool alongside a
    /// monitoring channel, and align its lifetime with the lifetime of the
    /// monitoring channel. If the monitoring channel collapses, the pool will
    /// be drained, and a new one may be created to replace it.
    ///
    /// Connection pools have two “size-like” variables:
    ///
    /// 1.  **Width**. A pool’s width is the conceptual size of the pool from
    ///     an availability perspective. It includes pending connections, but
    ///     does not include perished connections.
    ///
    ///     Width is regulated by the pool’s ``size`` parameters and ``rate``.
    ///
    /// 2.  **Count**. A pool’s count is the conceptual size of the pool from
    ///     a resource-allocation perspective. Count is equal to the pool width,
    ///     plus the number of perished connections known to the pool. A pool
    ///     is not considered fully-drained until its connection count reaches
    ///     zero.
    ///
    ///     Connection count is important to the semantics of the pool, but
    ///     is only publicly observable through the behavior of its ``drain``
    ///     method.
    public
    actor ConnectionPool
    {
        /// The generation number of this connection pool. The pool attaches this
        /// token to every connection created from it.
        nonisolated
        let generation:UInt
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
        /// The target size of this connection pool. The pool will attempt to grow
        /// until it contains at least the minimum number of connections, and it will
        /// never exceed the maximum connection count.
        nonisolated
        let size:ClosedRange<Int>
        /// The maximum number of connections this pool can establish concurrently.
        nonisolated
        let rate:Int

        /// The connections stored in this pool.
        private
        var connections:Connections
        /// All requests currently awaiting connections, identified by `UInt`.
        private
        var requests:[UInt: CheckedContinuation<MongoChannel?, Never>]
        /// A monotonically-increasing counter used to generate request
        /// identifiers.
        private
        var counter:UInt
        /// The current stage of the pool’s lifecycle. Pools start out in the
        /// “filling” state, and eventually transition to the “draining” state,
        /// which is terminal. There are no “in-between” states.
        ///
        /// The implementation does not lint idle connections, so the pool width
        /// will only decrease during the filling stage if individual connections
        /// perish.
        private
        var state:State

        /// Avoid setting the maximum pool size to a very large number, because
        /// the pool makes no linting guarantees.
        init(generation:UInt, signaling heart:Heart,
            bootstrap:Bootstrap,
            host:Mongo.Host,
            size:ClosedRange<Int> = 0 ... 100,
            rate:Int = 2)
        {
            self.generation = generation
            self.timeout = bootstrap.timeout
            self.heart = heart
            self.host = host
            self.size = 0 ... 100
            self.rate = 2

            self.connections = .init()
            self.requests = [:]
            self.counter = 0

            self.state = .filling(.init(channel: bootstrap.bootstrap(for: host),
                _credentials: bootstrap.credentials,
                _appname: bootstrap.appname,
                host: host))

            let _:Task<Void, Never> = .init
            {
                await self.resize()
            }
        }
        deinit
        {
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
    /// The conceptual size of the pool from an availability perspective.
    /// This number counts pending connections, but does not count perished
    /// connections.
    var width:Int
    {
        self.connections.width
    }
}
extension Mongo.ConnectionPool
{
    /// Mints a new request identifier.
    private
    func request() -> UInt
    {
        self.counter += 1
        return self.counter
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
        if  let continuation:CheckedContinuation<MongoChannel?, Never> =
                self.requests.removeValue(forKey: request)
        {
            continuation.resume(returning: nil)
        }
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
    func drain() async
    {
        if case .draining(_?) = self.state
        {
            fatalError("unreachable (draining connection pool that is already being drained!)")
        }

        for request:CheckedContinuation<MongoChannel?, Never> in self.requests.values
        {
            request.resume(returning: nil)
        }
        self.requests = [:]

        //  move channels that we can directly close
        //  (as opposed to waiting for a client to release them)
        let released:Set<MongoChannel> = self.connections.shrink()
        
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
}

extension Mongo.ConnectionPool
{
    /// Returns a connection back to the pool. Every *successful* call to
    /// ``create(by:)`` must be paired with a call to `destroy(_:)`.
    ///
    /// The connection must have been created by this pool.
    public nonisolated
    func destroy(_ connection:Mongo.Connection)
    {
        guard self.generation == connection.generation
        else
        {
            fatalError("unreachable (destroying connection that was created by a different pool)")
        }
        let channel:MongoChannel = connection.channel
        let reuse:Bool = connection.reusable
        
        let _:Task<Void, Never> = .init
        {
            await self.checkin(channel: channel, reuse: reuse)
        }
    }
    /// Returns a connection if one is available, creating it if the pool has
    /// capacity for additional connections. Otherwise, blocks until one of those
    /// conditions is met, or the specified deadline passes.
    ///
    /// The deadline is not enforced if a connection is already available in the
    /// pool when the actor services the request.
    ///
    /// If the deadline passes while the pool is creating a connection for the
    /// caller, the call will error, but the connection will still be created
    /// and added to the pool, and may be used to complete a different request.
    public nonisolated
    func create(by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.Connection
    {
        if let channel:MongoChannel = await self.checkout(by: deadline)
        {
            return .init(generation: self.generation, channel: channel)
        }
        else
        {
            throw Mongo.ConnectionCheckoutError.init()
        }
    }
}
extension Mongo.ConnectionPool
{
    private
    func checkout(by deadline:Mongo.ConnectionDeadline) async -> MongoChannel?
    {
        while case .filling(let bootstrap) = self.state
        {
            if  let channel:MongoChannel = self.connections.checkout()
            {
                return channel
            }
            guard   self.connections.pending < self.rate,
                    self.connections.width < self.size.upperBound
            else
            {
                let request:UInt = self.request()

                async
                let _:Void = self.fail(request, by: deadline)

                return await withCheckedContinuation
                {
                    self.requests.updateValue($0, forKey: request)
                }
            }

            await self.grow(using: bootstrap)
        }

        return nil
    }
    private
    func checkin(channel:MongoChannel, reuse:Bool) async
    {
        switch self.state
        {
        case .filling:
            guard reuse
            else
            {
                await channel.close()
                self.connections.remove(channel)
                // pool lifecycle stage may have changed
                break
            }
            if let continuation:CheckedContinuation<MongoChannel?, Never> =
                    self.requests.popFirst()?.value
            {
                continuation.resume(returning: channel)
                return
            }
            else
            {
                self.connections.checkin(channel)
                return
            }
        
        case .draining:
            //  we have to wait for the channel to close before removing
            //  it from the retained list, because a re-entrant call to this
            //  method might observe `self.count == 0` while the channel is
            //  still open.
            await channel.close()
            self.connections.remove(channel)
        }

        if  self.connections.isEmpty,
            case .draining(let continuation?) = self.state
        {
            continuation.resume()
            self.state = .draining(nil)
        }
    }
    /// Checks if the pool’s width is below its desired ``size``, and
    /// calls ``grow(using:)`` if so. Does nothing if the pool is draining
    /// or if ``rate`` connections are already being created.
    private
    func resize() async
    {
        if  case .filling(let bootstrap) = self.state,
            self.connections.pending < self.rate,
            self.connections.width < self.size.lowerBound
        {
            await self.grow(using: bootstrap)
        }
    }
    /// Marks the given channel as “perished”, and triggers a pool ``resize``.
    /// In practice, this means the channel will only be replaced if the
    /// width of the pool would fall below [`size.lowerBound`]().
    private
    func replace(perished channel:MongoChannel) async
    {
        self.connections.perish(channel)
        await self.resize()
    }
    /// Tries to create and add a new connection to the pool. If anything goes wrong
    /// during this process, the ``stopMonitoring(throwing:)`` signal will be emitted
    /// if the pool is still in the filling stage when the error is observed, and
    /// the pool will immediately transition to its draining stage.
    ///
    /// If the pool is still in the filling stage when the connection is successfully
    /// established, it will trigger a (non-blocking) recursive call to this method
    /// via ``resize``. Because the call to ``resize`` is non-blocking, it is possible
    /// that no recursive call actually takes place, because a concurrent `grow(using:)`
    /// call may have already brought the pool back to a healthy width in the meantime.
    ///
    /// If the pool transitions to the draining stage while the connection is being
    /// created, the connection will be closed and the connection count decremented.
    /// Because a pending connection still contributes to connection count, this may
    /// unblock a call to ``drain``.
    private
    func grow(using bootstrap:Mongo.Connection.Bootstrap) async
    {
        do
        {
            self.connections.pending += 1

            let deadline:Mongo.ConnectionDeadline = self.timeout.deadline(from: .now)
            let channel:MongoChannel = try await bootstrap.channel(to: self.host, by: deadline)

            switch self.state
            {
            case .filling:
                channel.whenClosed
                {
                    _ in
                    let _:Task<Void, Never> = .init
                    {
                        await self.replace(perished: channel)
                    }
                }

                self.connections.insert(channel)
                self.connections.pending -= 1

                if  self.connections.pending < self.rate,
                    self.connections.width < self.size.lowerBound
                {
                    let _:Task<Void, Never> = .init
                    {
                        //  re-checks preconditions, since it may have been a while
                        //  since this task was initiated.
                        await self.resize()
                    }
                }

                return
            
            case .draining:
                await channel.close()
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

            switch self.state
            {
            case .filling:
                self.stopMonitoring(throwing: error)
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
}
