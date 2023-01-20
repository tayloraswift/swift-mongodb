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
    ///
    /// Create a session by calling ``init(from:)`` with a session pool.
    ///
    /// ```swift
    /// bootstrap.withSessionPool
    /// {
    ///     let session:Mongo.Session = .init(from: $0)
    /// }
    /// ```
    ///
    /// Never escape a session from the scope that its pool was yielded to.
    /// Methods that yield a session pool to a closure cannot return until every
    /// session created inside the closure has been deinitialized.
    public final
    class Session:Identifiable
    {
        /// The minimum operation time that subsequent operations using this
        /// session presume. Every command run on a session updates the
        /// precondition time in order to provide a guarantee of causal
        /// consistency.
        ///
        /// This is simply a long-winded way of saying that time never moves
        /// backward when running commands on a session.
        public private(set)
        var preconditionTime:Mongo.Instant?
        /// The current transaction state of this session.
        public private(set)
        var transaction:Transaction
        /// The local time when the last (successful) command was sent on this
        /// session.
        private
        var touched:ContinuousClock.Instant
        /// Whether or not this session should be re-indexed when it is given
        /// back to its session pool.
        private
        var reuse:Bool

        public
        let id:SessionIdentifier

        /// The server cluster associated with this session’s ``pool``.
        ///
        /// This can also be obtained by accessing `pool.cluster`, but is
        /// stored inline to speed up access.
        @usableFromInline
        let cluster:Cluster
        /// The pool this session came from. The pool cannot be drained until
        /// this session object is deinitialized.
        private
        let pool:SessionPool

        private
        init(metadata:SessionMetadata, pool:SessionPool)
        {
            self.preconditionTime = nil
            self.transaction = metadata.transaction
            self.touched = metadata.touched
            self.reuse = true
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
                reuse: self.reuse)
        }
    }
}
extension Mongo.Session
{
    /// Creates a session from a session pool. Do not escape the session
    /// from the scope that yielded the pool, because doing so will prevent
    /// the pool from draining on scope exit.
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
extension Mongo.Session
{
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
    @inlinable public
    func run<Command>(command:Command, against database:Command.Database,
        on preference:Mongo.ReadPreference = .primary,
        by deadline:ContinuousClock.Instant? = nil) async throws -> Command.Response
        where Command:MongoCommand
    {
        let connect:Mongo.ConnectionDeadline = self.cluster.timeout.deadline(from: .now,
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
        with consumer:(Mongo.Batches<Query.Element>) async throws -> Success)
        async throws -> Success
        where Query:MongoQuery
    {
        let connect:Mongo.ConnectionDeadline = self.cluster.timeout.deadline(from: .now,
            clamping: deadline)
        let connections:Mongo.ConnectionPool = try await self.cluster.pool(
            preference: preference,
            by: connect)
        let connection:Mongo.Connection = try await .init(from: connections, by: connect)
        
        return try await self.run(query: query, against: database,
            over: connection,
            on: preference,
            by: deadline ?? connect.instant,
            with: consumer)
    }

    @inlinable public
    func withTransaction<Success>(
        writeConcern:Mongo.WriteConcern?,
        readConcern:Mongo.ReadConcern?,
        run body:() async throws -> Success) async throws -> Success
    {
        self.startTransaction(with: readConcern)
        do
        {
            let success:Success = try await body()
            try await self.commitTransaction(with: writeConcern)
            return success
        }
        catch let error
        {
            try? await self.abortTransaction(with: writeConcern)
            throw error
        }
    }

    @usableFromInline
    func startTransaction(with readConcern:Mongo.ReadConcern?)
    {
        self.transaction.start(with: readConcern)
    }
    @usableFromInline
    func abortTransaction(with writeConcern:Mongo.WriteConcern?) async throws
    {
        defer
        {
            self.transaction.phase = nil
        }
        try await self.run(command: Mongo.AbortTransaction.init(writeConcern: writeConcern),
            against: .admin)
    }
    @usableFromInline
    func commitTransaction(with writeConcern:Mongo.WriteConcern?) async throws
    {
        defer
        {
            self.transaction.phase = nil
        }
        try await self.run(command: Mongo.CommitTransaction.init(writeConcern: writeConcern),
            against: .admin)
    }
    // @inlinable public
    // func runWithSnapshotTransaction<Command, Success>(command:Command,
    //     against database:Command.Database,
    //     by deadline:ContinuousClock.Instant? = nil,
    //     started:ContinuousClock.Instant = .now,
    //     _ body:(Command.Response) async throws -> Success) async throws -> Success
    //     where Command:MongoTransactableCommand
    // {
    //     let connect:Mongo.ConnectionDeadline = self.cluster.timeout.deadline(from: started,
    //         clamping: deadline)
    //     //  transactions are only supported on the primary
    //     let connections:Mongo.ConnectionPool = try await self.cluster.pool(
    //         preference: .primary,
    //         by: connect)
    //     let connection:Mongo.Connection = try await .init(from: connections, by: connect)

    //     self.startTransaction()
        
    //     let initial:Command.Response = try await self.run(command: command,
    //         against: database,
    //         over: connection,
    //         on: .primary,
    //         by: deadline ?? connect.instant)
        
    //     do
    //     {
    //         let success:Success = try await consumer(batches)
    //         await batches.destroy()
    //         return success
    //     }
    //     catch let error
    //     {
    //         await batches.destroy()
    //         throw error
    //     }
    // }
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
                .init(level: $0.readLevel, after: self.preconditionTime)
            },
            transaction: self.transaction,
            session: self.id)
        
        let sent:ContinuousClock.Instant = .now
        let reply:Mongo.Reply = try await connection.run(command: command,
            against: database,
            labels: labels,
            by: deadline)

        self.combine(operationTime: reply.operationTime,
            reuse: connection.reusable,
            sent: sent)
        self.cluster.yield(clusterTime: reply.clusterTime)

        return try Command.decode(reply: try reply.result.get())
    }

    @inlinable public
    func run<Query, Success>(query:Query, against database:Query.Database,
        over connection:Mongo.Connection,
        on preference:Mongo.ReadPreference,
        by deadline:ContinuousClock.Instant,
        with consumer:(Mongo.Batches<Query.Element>) async throws -> Success)
        async throws -> Success
        where Query:MongoQuery
    {
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
    /// Update the session’s state with an observed operation time, and the local
    /// time when the command it was obtained from was sent.
    ///
    /// -   Parameters:
    ///     -   operationTime:
    ///         The server-side operation time from the most-recently executed
    ///         command. This is used to enforce causal consistency for server
    ///         operations.
    ///     -   reuse:
    ///         Whether or not the connection used to execute the last command
    ///         experienced a network error. If false, this will set ``reuse``
    ///         to false. (But it will never make ``reuse`` true again.)
    ///     -   sent:
    ///         The local time when the last command was sent. This represents a
    ///         pessimistic assumption of when the server last observed a usage
    ///         of this session, and is used by the driver to estimate its
    ///         freshness.
    @usableFromInline
    func combine(operationTime:Mongo.Instant?, reuse:Bool, sent:ContinuousClock.Instant)
    {
        self.touched = sent
        self.reuse = self.reuse && reuse
        //  observed operation times will not necessarily be monotonic, if
        //  commands are being sent to different servers across the same
        //  session. to enforce causal consistency, we must only update the
        //  precondition time if it is greater than the stored precondition time.
        guard let operationTime:Mongo.Instant
        else
        {
            return
        }
        if let preconditionTime:Mongo.Instant = self.preconditionTime
        {
            self.preconditionTime = max(preconditionTime, operationTime)
        }
        else
        {
            self.preconditionTime = operationTime
        }
    }
}
