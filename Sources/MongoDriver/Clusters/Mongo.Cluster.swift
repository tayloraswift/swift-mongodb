import Atomics
import MongoChannel
import MongoTopology

extension Mongo
{
    public final
    actor Cluster
    {
        private
        var selectionRequests:[UInt: SelectionRequest]
        private
        var sessionsRequests:[UInt: SessionsRequest]
        private
        var counter:UInt

        private nonisolated
        let sessionTimeoutMinutes:UnsafeAtomic<Int64>

        private
        var snapshot:MongoTopology.Servers
        /// The current largest-seen cluster time, if any.
        public private(set)
        var time:ClusterTime

        init()
        {
            self.sessionTimeoutMinutes = .create(0)
            self.snapshot = .none
            self.time = .init(nil)

            self.selectionRequests = [:]
            self.sessionsRequests = [:]
            self.counter = 0
        }

        deinit
        {
            self.sessionTimeoutMinutes.destroy()

            guard self.selectionRequests.isEmpty
            else
            {
                fatalError("unreachable (deinitialized while selection requests are awaiting)")
            }
            guard self.sessionsRequests.isEmpty
            else
            {
                fatalError("unreachable (deinitialized while session requests are awaiting)")
            }
        }
    }
}
extension Mongo.Cluster
{
    nonisolated
    var sessions:Mongo.LogicalSessions?
    {
        let rawValue:Int64 = self.sessionTimeoutMinutes.load(ordering: .relaxed)
        return rawValue == 0 ? nil : .init(ttl: .init(rawValue: rawValue))
    }

    subscript(preference:Mongo.ReadPreference) -> MongoChannel?
    {
        switch preference
        {
        case    .primary:
            return self.snapshot[.primary]
        
        case    .primaryPreferred   (let eligibility, hedge: _),
                .nearest            (let eligibility, hedge: _),
                .secondaryPreferred (let eligibility, hedge: _),
                .secondary          (let eligibility, hedge: _):
            return self.snapshot[preference.mode, where: eligibility]
        }
    }
}
extension Mongo.Cluster
{
    @inlinable public nonisolated
    func push(time:Mongo.ClusterTime.Sample?)
    {
        guard let time:Mongo.ClusterTime.Sample
        else
        {
            return
        }
        let _:Task<Void, Never> = .init
        {
            await self.push(time: time)
        }
    }
    public
    func push(time:Mongo.ClusterTime.Sample)
    {
        self.time.combine(with: time)
    }
    func push(snapshot:MongoTopology.Servers, sessions:Mongo.LogicalSessions? = nil)
    {
        self.snapshot = snapshot

        for (id, request):(UInt, SelectionRequest) in self.selectionRequests
        {
            if  let channel:MongoChannel = self[request.preference]
            {
                self.selectionRequests[id].fulfill(with: channel)
            }
        }

        guard let sessions:Mongo.LogicalSessions
        else
        {
            return
        }

        switch self.sessions.map({ sessions.ttl < $0.ttl })
        {
        case nil, true?:
            self.sessionTimeoutMinutes.store(sessions.ttl.rawValue,
                ordering: .relaxed)
        case false?:
            break
        }

        for id:UInt in self.sessionsRequests.keys
        {
            self.sessionsRequests[id].fulfill(with: sessions)
        }
    }
}
extension Mongo.Cluster
{
    private
    func request() -> UInt
    {
        self.counter += 1
        return self.counter
    }
}
extension Mongo.Cluster
{
    /// Returns deployment-wide logical session parameters, without suspending,
    /// if the cluster is known to support logical sessions. Suspends for at most
    /// the specified amount of time otherwise, returning as soon as this
    /// information becomes available.
    ///
    /// This method often suspends if it is called immediately after initializing
    /// a session pool, because the pool did not have time to connect to any
    /// servers yet.
    public nonisolated
    func sessions(by deadline:ContinuousClock.Instant) async throws -> Mongo.LogicalSessions
    {
        if  let sessions:Mongo.LogicalSessions = self.sessions
        {
            return sessions
        }
        else
        {
            return try await self.sessionsAvailable(by: deadline)
        }
    }
    private
    func sessionsAvailable(
        by deadline:ContinuousClock.Instant) async throws -> Mongo.LogicalSessions
    {
        let id:UInt = self.request()

        async
        let _:Void = self.sessionsUnavailable(for: id, once: deadline)

        return try await withCheckedThrowingContinuation
        {
            self.sessionsRequests.updateValue(.init(promise: $0),
                forKey: id)
        }
    }
    private
    func sessionsUnavailable(for id:UInt, once instant:ContinuousClock.Instant) async throws
    {
        //  will throw ``CancellationError`` if request succeeds
        try await Task.sleep(until: instant, clock: .continuous)
        self.sessionsRequests[id].fail(diagnosing: self.snapshot)
    }
}
extension Mongo.Cluster
{
    public
    func select(preference:Mongo.ReadPreference,
        by deadline:ContinuousClock.Instant) async throws ->
    (
        clusterTime:Mongo.ClusterTime,
        selection:Mongo.Selection
    )
    {
        (
            self.time, .init(preference: preference,
                channel: try await self.channel(to: preference, by: deadline))
        )
    }
    private
    func channel(to preference:Mongo.ReadPreference,
        by deadline:ContinuousClock.Instant) async throws -> MongoChannel
    {
        if  let channel:MongoChannel = self[preference]
        {
            return channel
        }
        else
        {
            return try await self.channelAvailable(to: preference, by: deadline)
        }
    }
    private
    func channelAvailable(to preference:Mongo.ReadPreference,
        by deadline:ContinuousClock.Instant) async throws -> MongoChannel
    {
        let id:UInt = self.request()

        async
        let _:Void = self.channelUnavailable(for: id, once: deadline)

        return try await withCheckedThrowingContinuation
        {
            self.selectionRequests.updateValue(.init(preference: preference, promise: $0),
                forKey: id)
        }
    }
    private
    func channelUnavailable(for id:UInt, once instant:ContinuousClock.Instant) async throws
    {
        //  will throw ``CancellationError`` if request succeeds
        try await Task.sleep(until: instant, clock: .continuous)
        self.selectionRequests[id].fail(diagnosing: self.snapshot)
    }
}
extension Mongo.Cluster
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
    ///     A ``Void`` tuple if `sessions` was empty or the command was sent
    ///     and successfully executed; [`nil`]() if at least one session was
    ///     provided, but there were no suitable servers to send the command
    ///     to, or if the command was sent but it failed on the server’s side.
    ///
    /// This method will not submit any work to the actor if `sessions` is empty.
    nonisolated
    func end(sessions:__owned [Mongo.SessionIdentifier]) async -> Void?
    {
        if let command:Mongo.EndSessions = .init(sessions)
        {
            return try? await self.run(endSessions: command)
        }
        else
        {
            return ()
        }
    }
    private
    func run(endSessions command:__owned Mongo.EndSessions) async throws -> Void?
    {
        try await self[.primaryPreferred]?.run(endSessions: command)
    }
}
