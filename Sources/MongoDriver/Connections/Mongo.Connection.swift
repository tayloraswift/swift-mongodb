import MongoCommands
import MongoExecutor
import MongoWire

extension Mongo
{
    /// A connection to a server that was created from a connection pool.
    ///
    /// Connections are mutable move-only types; this is currently implemented
    /// as a reference type. The connection will be returned to its pool on
    /// `deinit`.
    public final
    class Connection:Identifiable
    {
        @usableFromInline internal
        let allocation:ConnectionPool.Allocation

        @usableFromInline internal
        let pool:ConnectionPool

        @usableFromInline internal
        var reuse:Bool

        private
        init(allocation:ConnectionPool.Allocation, pool:ConnectionPool)
        {
            self.allocation = allocation
            self.pool = pool

            self.reuse = true
        }
        deinit
        {
            self.pool.destroy(allocation, reuse: self.reuse)
        }
    }
}
@available(*, unavailable, message: "connections are mutable move-only types.")
extension Mongo.Connection:Sendable
{
}
extension Mongo.Connection
{
    public
    var id:UInt
    {
        self.allocation.id
    }
}
extension Mongo.Connection
{
    /// Obtains a connection from the given pool if one is available, creating it
    /// if the pool has capacity for additional connections. Otherwise, blocks
    /// until one of those conditions is met, or the specified deadline passes.
    ///
    /// The deadline is not enforced if a connection is already available in the
    /// pool when its actor services the request.
    ///
    /// If the deadline passes while the pool is creating a connection for the
    /// caller, the call will error, but the connection will still be created
    /// and added to the pool, and may be used to complete a different request.
    public convenience
    init(from pool:Mongo.ConnectionPool, by deadline:ContinuousClock.Instant) async throws
    {
        self.init(allocation: try await pool.create(by: deadline), pool: pool)
    }
}
extension Mongo.Connection
{
    /// Indicates if the connection is believed to be reusable,
    /// meaning it has not experienced a network error or a protocol
    /// error that would invalidate subsequent commands run over this
    /// connection.
    @inlinable public
    var reusable:Bool
    {
        self.reuse
    }
    /// Interrupts this connection’s IO channel, and marks it as
    /// non-reusable.
    @_spi(testable)
    public
    func crosscancel(throwing error:any Error)
    {
        self.allocation.crosscancel(throwing: error)
        self.reuse = false
    }
}
extension Mongo.Connection
{
    @inlinable public
    func run<Command>(command:__owned Command,
        against database:Command.Database,
        labels:Mongo.SessionLabels,
        by deadline:ContinuousClock.Instant) async throws -> Mongo.Reply
        where Command:Mongo.Command
    {
        let deadline:ContinuousClock.Instant = self.pool.adjust(deadline: deadline)
        guard
        let command:Mongo.WireMessage.Sections = command.encode(
            database: database,
            labels: labels,
            by: deadline)
        else
        {
            throw Mongo.DriverTimeoutError.init()
        }

        let message:Mongo.WireMessage

        do
        {
            message = try await self.allocation.request(sections: command, deadline: deadline)
        }
        catch let error
        {
            self.reuse = false
            throw error
        }

        return try .init(message: message)
    }
}
