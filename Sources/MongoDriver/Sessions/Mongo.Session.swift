extension Mongo
{
    /// Tracks a session on a MongoDB server. Sessions have reference semantics.
    ///
    /// Sessions are not ``Sendable``, because their purpose is to provide a
    /// guarantee of causual consistency between asynchronous operations.
    /// (“Read your writes”.) Therefore using the same session from
    /// concurrently-executing code without some other means of regulating
    /// command dispatch does not make sense.
    ///
    /// Most of the time when you want to perform concurrent operations
    /// on a database, you want each task to checkout its own session from a
    /// ``SessionPool``, which is ``Sendable``.
    public
    struct Session:Identifiable
    {
        public
        let connectionTimeout:Duration
        public
        let cluster:Mongo.Cluster
        @usableFromInline
        let state:State

        public
        let id:SessionIdentifier

        init(on cluster:Mongo.Cluster,
            connectionTimeout:Duration,
            metadata:SessionMetadata,
            id:SessionIdentifier)
        {
            self.state = .init(metadata)

            self.connectionTimeout = connectionTimeout
            self.cluster = cluster
            self.id = id
        }
    }
}
@available(*, unavailable, message: "sessions have reference semantics")
extension Mongo.Session:Sendable
{
}
extension Mongo.Session
{
    @inlinable public
    func deadline(from start:ContinuousClock.Instant = .now) -> ContinuousClock.Instant
    {
        start.advanced(by: self.connectionTimeout)
    }
}
extension Mongo.Session
{    
    @inlinable public
    func runner(preference:Mongo.ReadPreference) async throws ->
    (
        clusterTime:Mongo.ClusterTime,
        runner:Mongo.UnsafeRunner
    )
    {
        let (time, selection):(Mongo.ClusterTime, Mongo.Selection) =
            try await self.cluster.select(preference: preference, by: self.deadline())
        return (time, .init(selection: selection, session: self))
    }

    /// Runs a session command against the ``Mongo/Database/.admin`` database.
    @inlinable public
    func run<Command>(command:Command,
        on preference:Mongo.ReadPreference = .primary) async throws -> Command.Response
        where Command:MongoSessionCommand
    {
        let (clusterTime, runner):(Mongo.ClusterTime, Mongo.UnsafeRunner) =
            try await self.runner(preference: preference)
        return try await runner.run(command: command, against: .admin,
            clusterTime: clusterTime)
    }
    
    /// Runs a session command against the specified database.
    @inlinable public
    func run<Command>(command:Command,
        against database:Mongo.Database,
        on preference:Mongo.ReadPreference = .primary)
        async throws -> Command.Response
        where Command:MongoSessionCommand & MongoDatabaseCommand
    {
        let (clusterTime, runner):(Mongo.ClusterTime, Mongo.UnsafeRunner) =
            try await self.runner(preference: preference)
        return try await runner.run(command: command, against: database,
            clusterTime: clusterTime)
    }
}

extension Mongo.Session
{
    @inlinable public
    func run<Query, Success>(query:Query, against database:Mongo.Database,
        on preference:Mongo.ReadPreference = .primary,
        with consumer:(Mongo.Batches<Query.Element>) async throws -> Success)
        async throws -> Success
        where Query:MongoQuery
    {
        let (initialTime, runner):(Mongo.ClusterTime, Mongo.UnsafeRunner) =
            try await self.runner(preference: preference)
        
        let batches:Mongo.Batches<Query.Element> = .init(runner: runner,
            initial: try await runner.run(command: query, against: database,
                clusterTime: initialTime),
            timeout: query.tailing?.timeout,
            stride: query.stride)
        let result:Result<Success, any Error>
        do
        {
            result = .success(try await consumer(batches))
        }
        catch let error
        {
            result = .failure(error)
        }
        try await batches.deinit()
        return try result.get()
    }
}
