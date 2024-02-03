import Atomics
import Durations
import Durations_Atomics
import MongoClusters

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
        public nonisolated
        let settings:ConnectionPoolSettings

        /// The host this pool creates connections to.
        public nonisolated
        let host:Host

        /// A handle for communicating back to the initiator of this pool.
        nonisolated
        let monitor:MonitorDelegate
        private nonisolated
        let logger:Logger?

        /// The connections stored in this pool.
        private
        var allocations:Allocations
        /// The number of connections that this pool knows have been released,
        /// but has not been able to re-index yet.
        private nonisolated
        let releasing:UnsafeAtomic<Int>

        private nonisolated
        let _latency:UnsafeAtomic<Nanoseconds>

        nonisolated
        var latency:UnsafeAtomic<Nanoseconds>
        {
            _read { yield self._latency }
        }

        /// Avoid setting the maximum pool size to a very large number, because
        /// the pool makes no linting guarantees.
        init(alongside monitor:MonitorDelegate,
            connectionTimeout:Milliseconds,
            connectorFactory:__shared ConnectorFactory,
            authenticator:Authenticator,
            generation:UInt,
            settings:ConnectionPoolSettings,
            latency:Nanoseconds,
            logger:Logger?,
            host:Host)
        {
            self.generation = generation
            self.settings = settings
            self.host = host

            self.monitor = monitor
            self.logger = logger

            self.allocations = .init(connector: connectorFactory(authenticator: authenticator,
                timeout: connectionTimeout,
                host: host))

            self.releasing = .create(0)
            self._latency = .create(latency)

        }
        deinit
        {
            self.allocations.destroy()

            self.releasing.destroy()
            self._latency.destroy()
        }
    }
}
extension Mongo.ConnectionPool
{
    func start() async
    {
        await withTaskCancellationHandler
        {
            await withCheckedContinuation
            {
                self.allocations.whenEmpty(resume: $0)

                let _:Task<Void, Never> = .init
                {
                    await self.fill()
                }

                self.log(.creating(self.settings))
            }
        }
        onCancel:
        {
            self.monitor.resume(from: .pool)

            let error:CancellationError = .init()
            let _:Task<Void, Never> = .init
            {
                await self.drain(throwing: .init(because: error, host: self.host))
            }

            self.log(.draining(because: error))
        }
    }
    private
    func drain(throwing error:Mongo.ConnectionPoolDrainedError)
    {
        self.allocations.drain(throwing: error)
    }
}
extension Mongo.ConnectionPool
{
    /// The number of non-perished connections, including pending connections,
    /// currently in the pool.
    ///
    /// Connection count is regulated by the pool’s ``Parameters/size`` and
    /// ``Parameters/rate`` parameters.
    public
    var count:Int
    {
        self.allocations.count
    }
}
extension Mongo.ConnectionPool
{
    /// Adjusts the given deadline to account for round-trip latency, as
    /// tracked by this pool.
    public nonisolated
    func adjust(deadline:ContinuousClock.Instant) -> ContinuousClock.Instant
    {
        deadline - .nanoseconds(self._latency.load(ordering: .relaxed))
    }
}
extension Mongo.ConnectionPool
{
    nonisolated
    func log(samplerEvent:Mongo.SamplerEvent)
    {
        self.logger?.yield(level: .full, event: .sampler(host: self.host,
            generation: self.generation,
            event: samplerEvent))
    }
    nonisolated
    func log(listenerEvent:Mongo.ListenerEvent)
    {
        self.logger?.yield(level: .full, event: .listener(host: self.host,
            generation: self.generation,
            event: listenerEvent))
    }
    nonisolated
    func log(topologyEvent:Mongo.TopologyModelEvent)
    {
        self.logger?.yield(level: .full, event: .topology(host: self.host,
            generation: self.generation,
            event: topologyEvent))
    }

    private nonisolated
    func log(_ event:Mongo.ConnectionPoolEvent)
    {
        self.logger?.yield(level: .full, event: .pool(host: self.host,
            generation: self.generation,
            event: event))
    }
}

extension Mongo.ConnectionPool
{
    /// Sleeps until the specified deadline, then fails the specified connection
    /// request if it is still awaiting. It is expected that the duration of this
    /// call will be shortened via task cancellation if the request succeeds
    /// before the deadline.
    private
    func fail(request id:UInt, by deadline:ContinuousClock.Instant) async throws
    {
        //  will throw ``CancellationError`` if request succeeds
        try await Task.sleep(until: deadline, clock: .continuous)
        self.allocations.fail(request: id, throwing: Mongo.ConnectionPoolTimeoutError.init(
            host: self.host))
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
    /// caller, the call will return nil, but the allocation will still be
    /// created and added to the pool, and may be used to complete a different
    /// request.
    func create(by deadline:ContinuousClock.Instant) async throws -> Allocation
    {
        while true
        {
            switch self.allocations.next(
                releasing: self.releasing.load(ordering: .relaxed),
                settings: self.settings)
            {
            case .available(let allocation):
                return allocation

            case .reserved(let reservation):
                // note: this checks for awaiting requests, and may use the
                // newly-established connection to succeed a different request.
                // so it is not guaranteed that the next iteration of the loop
                // will yield a channel.
                await self.fill(reservation: reservation)

            case .blocked(let id):
                async
                let _:Void = self.fail(request: id, by: deadline)

                return try await withCheckedThrowingContinuation
                {
                    self.allocations.submit(request: id, resuming: $0)
                }

            case .failure(let error):
                throw error
            }
        }
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
    ///         If `false`, the channel will be asynchronously closed and
    ///         removed from the pool.
    ///
    /// Every *successful* call to ``create(by:)`` must be paired with a call
    /// to `destroy(_:reuse:)`.
    ///
    /// If `reuse` is `true`, later calls to ``create(by:)`` will wait for
    /// the destroyed connection to be re-indexed, instead of establishing a new
    /// one, provided that there are more un-indexed connections than
    /// currently-blocked requests.
    ///
    /// If `reuse` is `false`, this method does not replace the connection,
    /// because replacement is performed when the underlying channel closes,
    /// which may take place before the wrapping connection is destroyed.
    nonisolated
    func destroy(_ allocation:Allocation, reuse:Bool)
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
    func destroy(_ allocation:Allocation, reindex:Bool) async
    {
        if  reindex
        {
            self.releasing.wrappingDecrement(ordering: .relaxed)
        }

        switch self.allocations.phase
        {
        case .connecting:
            guard reindex
            else
            {
                fallthrough
            }

            self.allocations.reindex(allocation)

        case .draining:
            //  we have to wait for the channel to close before removing
            //  it from the retained list, because a re-entrant call to this
            //  method might observe `self.count == 0` while the channel is
            //  still open.
            await allocation.close()
            self.allocations.deindex(allocation.id)
        }

    }
    /// Marks the given channel as “perished”, and replaces it (by dispatching
    /// to ``fill(using:)``) if the pool is in its connecting stage.
    /// If the pool is in the draining stage, and perishing the channel reduced
    /// the connection count to zero, calling this method may unblock a call to
    /// ``drain``.
    private
    func replace(perished allocation:Allocation) async
    {
        if  let reservation:Reservation = self.allocations.replace(allocation.id,
                releasing: self.releasing.load(ordering: .relaxed),
                settings: self.settings)
        {
            await self.fill(reservation: reservation)
        }
    }
    /// Checks if the pool is (still) in its connecting phase and calls
    /// ``fill(using:)`` if so. Does nothing if the pool is draining.
    private
    func fill() async
    {
        if  let reservation:Reservation = self.allocations.reserve(
                releasing: self.releasing.load(ordering: .relaxed),
                settings: self.settings)
        {
            await self.fill(reservation: reservation)
        }
    }
    private
    func fill(reservation:Reservation) async
    {
        self.log(.expanding(id: reservation.id))

        let allocation:Allocation

        do
        {
            allocation = try await reservation.connect()
        }
        catch let error
        {
            self.monitor.resume(from: .pool)

            self.allocations.drain(throwing: .init(because: error, host: self.host),
                erase: true)

            self.log(.draining(because: error))
            return
        }

        switch self.allocations.phase
        {
        case .draining:
            await allocation.close()
            self.allocations.erase()

        case .connecting:
            allocation.channel.closeFuture.whenComplete
            {
                self.log(.perished(id: allocation.id, because: $0))

                let _:Task<Void, Never> = .init
                {
                    await self.replace(perished: allocation)
                }
            }

            self.log(.expanded(id: allocation.id))

            self.allocations.fill(with: allocation)

            if  self.allocations.expandable(
                    releasing: self.releasing.load(ordering: .relaxed),
                    settings: self.settings)
            {
                let _:Task<Void, Never> = .init
                {
                    //  re-checks preconditions, since it may have been a while
                    //  since this task was initiated.
                    await self.fill()
                }
            }
        }
    }
}
