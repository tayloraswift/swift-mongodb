import Durations

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
    public final
    class Session
    {
        public private(set)
        var operationTime:OperationTime
        public private(set)
        var transaction:Transaction
        private
        var touched:ContinuousClock.Instant

        public
        let id:SessionIdentifier

        /// The server cluster associated with this session’s ``pool``.
        /// This is stored inline to speed up access.
        @usableFromInline
        let cluster:Cluster
        private
        let pool:SessionPool

        private
        init(metadata:SessionMetadata, pool:SessionPool)
        {
            self.operationTime = .init(nil)
            self.transaction = metadata.transaction
            self.touched = metadata.touched
            self.id = metadata.id

            self.cluster = pool.cluster
            self.pool = pool
        }
        deinit
        {
            self.pool.destroy(.init(
                    transaction: self.transaction,
                    touched: self.touched,
                    id: self.id),
                reuse: true)
        }
    }
}
extension Mongo.Session
{
    public convenience
    init(from pool:Mongo.SessionPool) async throws
    {
        self.init(metadata: try await pool.create(), pool: pool)
    }
}
@available(*, unavailable, message: "sessions have reference semantics")
extension Mongo.Session:Sendable
{
}
extension Mongo.Session:Identifiable
{
    @usableFromInline
    func combine(operationTime:Mongo.Instant?, sent:ContinuousClock.Instant)
    {
        self.touched = sent
        //  observed operation times will not necessarily be monotonic, if
        //  commands are being sent to different servers across the same
        //  session. to enforce causal consistency, we must only update the
        //  operation time if it is greater than the stored operation time.
        if let operationTime:Mongo.Instant
        {
            self.operationTime.combine(with: operationTime)
        }
    }
}
extension Mongo.Session
{    
    @inlinable public
    func run<Command>(command:Command, against database:Command.Database,
        over connection:Mongo.Connection,
        on preference:Mongo.ReadPreference,
        by deadline:ContinuousClock.Instant) async throws -> Command.Response
        where Command:MongoCommand
    {
        let labels:Mongo.SessionLabels = .init(clusterTime: self.cluster.time,
            readPreference: preference,
            readConcern: (command as? any MongoReadCommand).map
            {
                .init(level: $0.readLevel, after: self.operationTime.max)
            },
            transaction: self.transaction,
            session: self.id)
        
        let sent:ContinuousClock.Instant = .now
        let reply:Mongo.Reply = try await connection.run(command: command,
            against: database,
            labels: labels,
            by: deadline)

        self.combine(operationTime: reply.operationTime, sent: sent)
        self.cluster.yield(clusterTime: reply.clusterTime)

        return try Command.decode(reply: try reply.result.get())
    }
    /// Runs a command against the specified database, on a server selected according
    /// to the specified read preference.
    ///
    /// -   Parameters:
    ///     -   command:
    ///         The command to run.
    ///     -   database:
    ///         The database to run the command against.
    ///     -   preference:
    ///         The read preference to use for server selection.
    ///     -   deadline:
    ///         A deadline used to enforce operation timeouts. If [`nil`](),
    ///         the default driver connection timeout will also be used as
    ///         the timeout for the entire operation.
    ///     -   started:
    ///         The time that is considered when the operation was “started”,
    ///         and which computed deadlines are relative to.
    @inlinable public
    func run<Command>(command:Command, against database:Command.Database,
        on preference:Mongo.ReadPreference = .primary,
        by deadline:ContinuousClock.Instant? = nil,
        started:ContinuousClock.Instant = .now) async throws -> Command.Response
        where Command:MongoCommand
    {
        let connect:Mongo.ConnectionDeadline = self.cluster.timeout.deadline(from: started,
            clamping: deadline)
        let connections:Mongo.ConnectionPool = try await self.cluster.pool(
            preference: preference,
            by: connect)
        let connection:Mongo.Connection = try await .init(from: connections, by: connect)
        return try await self.run(command: command, against: database,
            over: connection,
            on: preference,
            by: deadline ?? connect.instant)
    }
}
extension Mongo.Session
{
    /// Runs an iterable command against the specified database, on a server selected
    /// according to the specified read preference.
    ///
    /// -   Parameters:
    ///     -   consumer:
    ///         A closure that will be called with an iterable sequence of ``Batches``.
    ///         if the closure returns while the cursor is still open, this method will
    ///         run ``KillCursors`` and wait for it to either complete or error.
    ///
    /// This method always makes a best-effort to destroy the cursor it creates, if it
    /// is still open after the closure parameter returns. This only happens if the
    /// consumer aborts iteration before obtaining the final batch of results, and this
    /// is the only situation where this method will block on exit.
    /// 
    /// This method will not block on exit in the following situations:
    ///
    /// -   The consumer completes iteration of the cursor, in which case it is already
    ///     known that the cursor is dead.
    /// -   An error was thrown by the cursor while it was being iterated, in which case
    ///     the cursor had already attempted to kill itself eagerly before propogating
    ///     the error to the consumer.
    @inlinable public
    func run<Query, Success>(query:Query, against database:Query.Database,
        on preference:Mongo.ReadPreference = .primary,
        by deadline:ContinuousClock.Instant? = nil,
        started:ContinuousClock.Instant = .now,
        with consumer:(Mongo.Batches<Query.Element>) async throws -> Success)
        async throws -> Success
        where Query:MongoQuery
    {
        let connect:Mongo.ConnectionDeadline = self.cluster.timeout.deadline(from: started,
            clamping: deadline)
        let connections:Mongo.ConnectionPool = try await self.cluster.pool(
            preference: preference,
            by: connect)
        let connection:Mongo.Connection = try await .init(from: connections, by: connect)
        
        let deadline:ContinuousClock.Instant = deadline ?? connect.instant
        let batches:Mongo.Batches<Query.Element> = .create(preference: preference,
            lifecycle: query.tailing.map { .iterable($0.timeout) } ?? .expires(deadline),
            timeout: .init(
                milliseconds: self.cluster.timeout.milliseconds),
            initial: try await self.run(command: query,
                against: database,
                over: connection,
                on: preference,
                by: deadline),
            stride: query.stride,
            pinned: (connection, self))
        
        do
        {
            let success:Success = try await consumer(batches)
            await batches.destroy()
            return success
        }
        catch let error
        {
            await batches.destroy()
            throw error
        }
    }
}
extension Mongo.Session
{
    /// Runs a ``RefreshSessions`` command. Calling this convenience method is equivalent
    /// to constructing a ``RefreshSessions`` instance with this session’s ``id`` and
    /// running it manually.
    public
    func refresh(on preference:Mongo.ReadPreference = .primary) async throws
    {
        try await self.run(command: Mongo.RefreshSessions.init(self.id),
            against: .admin,
            on: preference)
    }
}
