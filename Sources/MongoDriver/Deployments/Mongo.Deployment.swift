import Atomics
import Durations

extension Mongo
{
    /// A type that models the state of a MongoDB deployment.
    ///
    /// Instances of this type are responsible for storing the following information:
    ///
    /// -   Whether or not the deployment supports logical sessions, and if so,
    ///     what the logical session TTL is.
    /// -   What the current largest-seen cluster time is, and proof that that
    ///     cluster time came from a `mongod`/`mongos` server.
    /// -   A snapshot of the current deployment topology, which contains references
    ///     to the current ``ConnectionPool`` associated with each reachable server.
    ///
    /// Instances of this type are responsible for making this information available
    /// to other tasks in a timely fashion. It is not responsible for computing or
    /// sequencing topology updates.
    ///
    /// Having a separate actor loop for publishing the deployment model means
    /// types like ``Session`` and ``SessionPool`` don’t need to interact with
    /// the service monitor, and service monitoring computations don’t block requests
    /// for information about deployment state.
    public final
    actor Deployment
    {
        /// The default timeout for driver operations.
        @usableFromInline internal nonisolated
        let timeout:Timeout
        //  Right now, we don’t do anything with this from this type. But other
        //  types use it through their deployment pointers.
        internal nonisolated
        let logger:Logger?

        private
        var capabilityRequests:[UInt: CapabilityRequest]
        private
        var selectionRequests:[UInt: SelectionRequest]
        private
        var counter:UInt

        private
        var servers:ServerTable

        private nonisolated
        let _capabilities:UnsafeAtomic<DeploymentCapabilities.BitPattern>
        private nonisolated
        let _clusterTime:UnsafeAtomic<AtomicState<ClusterTime>?>

        init(connectionTimeout:Milliseconds, logger:Logger?)
        {
            self.timeout = .init(default: connectionTimeout)
            self.logger = logger

            self._capabilities = .create(.init(nil))
            self._clusterTime = .create(nil)

            self.capabilityRequests = [:]
            self.selectionRequests = [:]
            self.counter = 0

            self.servers = .none
        }

        /// The current largest-seen cluster time, if any.
        public nonisolated
        var clusterTime:Mongo.ClusterTime?
        {
            self._clusterTime.load(ordering: .relaxed)?.value
        }
        public nonisolated
        var capabilities:Mongo.DeploymentCapabilities?
        {
            .init(bitPattern: self._capabilities.load(ordering: .relaxed))
        }

        deinit
        {
            self._capabilities.destroy()
            self._clusterTime.destroy()

            guard self.selectionRequests.isEmpty
            else
            {
                fatalError("unreachable (deinitialized while selection requests are awaiting!)")
            }
            guard self.capabilityRequests.isEmpty
            else
            {
                fatalError("unreachable (deinitialized while session requests are awaiting!)")
            }
        }
    }
}

extension Mongo.Deployment
{
    /// Synchronously yield an observed cluster time to this deployment model.
    /// The time sample will be integrated into the deployment state
    /// asynchronously.
    ///
    /// It is expected that many concurrent tasks will yield non-monotinic
    /// cluster time observations; the deployment model will sequence the
    /// observations and publish a monotonically increasing global cluster time.
    ///
    /// This works differently from topology snapshot updates, which are pushed
    /// by a single actor loop (the `Monitor`) in a blocking fashion.
    @usableFromInline nonisolated
    func yield(clusterTime:Mongo.ClusterTime?)
    {
        guard let clusterTime:Mongo.ClusterTime
        else
        {
            return
        }
        let _:Task<Void, Never> = .init
        {
            await self.combine(clusterTime)
        }
    }
    /// Updates the stored cluster time if the given time is greater. This is
    /// actor-isolated even though it only uses non-isolated operations, to prevent
    /// races between the atomic load and the atomic store.
    private
    func combine(_ clusterTime:Mongo.ClusterTime)
    {
        let current:Mongo.AtomicState<Mongo.ClusterTime>? = self._clusterTime.load(
            ordering: .relaxed)
        self._clusterTime.store(clusterTime.combined(with: current),
            ordering: .relaxed)
    }
}
extension Mongo.Deployment
{
    /// Pushes a server table to the deployment model.
    ///
    /// Unlike the cluster time, topology updates are computationally intensive, and
    /// so they are not calculated on the deployment model’s actor loop, to avoid
    /// blocking tasks that need to read the deployment state.
    ///
    /// This method should only be called from a single task or actor context, and
    /// the caller should always wait for the call to complete in order to ensure
    /// sequential consistency.
    func push(table servers:Mongo.ServerTable)
    {
        self._capabilities.store(.init(servers.capabilities), ordering: .relaxed)
        self.servers = servers

        for (id, request):(UInt, SelectionRequest) in self.selectionRequests
        {
            if  let pool:Mongo.ConnectionPool = self.servers[request.preference]
            {
                self.selectionRequests[id].fulfill(with: pool)
            }
        }

        if let capabilities:Mongo.DeploymentCapabilities = servers.capabilities
        {
            for id:UInt in self.capabilityRequests.keys
            {
                self.capabilityRequests[id].fulfill(with: capabilities)
            }
        }
    }
}
extension Mongo.Deployment
{
    private
    func request() -> UInt
    {
        self.counter += 1
        return self.counter
    }
}
extension Mongo.Deployment
{
    /// Returns deployment-wide logical session parameters, without suspending,
    /// if the deployment is known to support logical sessions. Suspends for at
    /// most the specified amount of time otherwise, returning as soon as this
    /// information becomes available.
    ///
    /// This method often suspends if it is called immediately after initializing
    /// a session pool, because the pool did not have time to connect to any
    /// servers yet.
    nonisolated
    func capabilities(
        by deadline:ContinuousClock.Instant) async throws -> Mongo.DeploymentCapabilities
    {
        if  let capabilities:Mongo.DeploymentCapabilities = self.capabilities
        {
            capabilities
        }
        else
        {
            try await self.capabilities(by: deadline).get()
        }
    }
    private
    func capabilities(
        by deadline:ContinuousClock.Instant) async -> CapabilityResponse
    {
        let id:UInt = self.request()

        async
        let _:Void = self.fail(capabilityRequest: id, once: deadline)

        return await withCheckedContinuation
        {
            self.capabilityRequests.updateValue(.init(promise: $0),
                forKey: id)
        }
    }
    private
    func fail(capabilityRequest id:UInt,
        once deadline:ContinuousClock.Instant) async throws
    {
        //  will throw ``CancellationError`` if request succeeds
        try await Task.sleep(until: deadline, clock: .continuous)
        self.capabilityRequests[id].fail(diagnosing: self.servers)
    }
}
extension Mongo.Deployment
{
    @usableFromInline internal
    func pool(selecting preference:Mongo.ReadPreference,
        by deadline:ContinuousClock.Instant) async throws -> Mongo.ConnectionPool
    {
        try await self.select(preference, by: deadline).get()
    }
    func select(_ preference:Mongo.ReadPreference,
        by deadline:ContinuousClock.Instant) async -> SelectionResponse
    {
        if  let pool:Mongo.ConnectionPool = self.servers[preference]
        {
            return .success(pool)
        }

        let id:UInt = self.request()

        async
        let _:Void = self.fail(selectionRequest: id, once: deadline)

        return await withCheckedContinuation
        {
            self.selectionRequests.updateValue(.init(preference: preference, promise: $0),
                forKey: id)
        }
    }
    private
    func fail(selectionRequest id:UInt, once deadline:ContinuousClock.Instant) async throws
    {
        //  will throw ``CancellationError`` if request succeeds
        try await Task.sleep(until: deadline, clock: .continuous)
        self.selectionRequests[id].fail(diagnosing: self.servers)
    }
}
extension Mongo.Deployment
{
    /// Sends an ``EndSessions`` command ending the given list of sessions
    /// to an appropriate server for this deployment’s topology, and awaits
    /// its response.
    ///
    /// -   Parameters:
    ///     -   sessions:
    ///         A list of sessions to include with the ``EndSessions``
    ///         command. This method will return immediately without
    ///         sending any command if `sessions` is empty.
    ///
    /// -   Returns:
    ///     `true` if `sessions` was empty or the command was sent
    ///     and successfully executed; `false` if at least one session was
    ///     provided, but there were no suitable servers to send the command
    ///     to, or if the command was sent but it failed on the server’s side.
    ///
    /// This method will not submit any work to the actor if `sessions` is empty.
    @discardableResult
    nonisolated
    func end(sessions:__owned [Mongo.SessionIdentifier]) async -> Bool
    {
        guard let command:Mongo.EndSessions = .init(sessions)
        else
        {
            return true
        }
        do
        {
            let deadline:ContinuousClock.Instant = self.timeout.deadline()

            let connections:Mongo.ConnectionPool = try await self.pool(
                selecting: .primaryPreferred,
                by: deadline)
            let connection:Mongo.Connection = try await .init(from: connections,
                by: deadline)

            let reply:Mongo.Reply = try await connection.allocation.run(command: command,
                against: .admin,
                by: deadline)

            return reply.ok
        }
        catch
        {
            return false
        }
    }
}
