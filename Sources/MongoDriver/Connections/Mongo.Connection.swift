import BSON
import BSONDSL
import MongoChannel
import MongoWire
import NIOCore

extension Mongo
{
    /// A connection to a server that was created from a connection pool.
    ///
    /// Connections are mutable move-only types; this is currently implemented
    /// as a reference type. The connection will be returned to its pool on
    /// `deinit`.
    public final
    class Connection
    {
        @usableFromInline
        let channel:MongoChannel
        private
        let pool:ConnectionPool

        @usableFromInline
        var reuse:Bool

        private
        init(channel:MongoChannel, pool:Mongo.ConnectionPool)
        {
            self.channel = channel
            self.pool = pool

            self.reuse = true
        }
        deinit
        {
            self.pool.destroy(channel, reuse: self.reuse)
        }
    }
}
@available(*, unavailable, message: "connections are mutable move-only types.")
extension Mongo.Connection:Sendable
{
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
    init(from pool:Mongo.ConnectionPool, by deadline:Mongo.ConnectionDeadline) async throws
    {
        if  let channel:MongoChannel = await pool.create(by: deadline)
        {
            self.init(channel: channel, pool: pool)
        }
        else
        {
            throw Mongo.ConnectionCheckoutError.init()
        }
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
    public
    func interrupt()
    {
        self.channel.interrupt()
        self.reuse = false
    }
}
extension Mongo.Connection
{
    @inlinable public
    func run<Command>(command:__owned Command,
        against database:Command.Database,
        labels:Mongo.SessionLabels? = nil,
        by deadline:ContinuousClock.Instant) async throws -> Mongo.Reply
        where Command:MongoCommand
    {
        let message:MongoWire.Message<ByteBufferView>?
        do
        {
            message = try await self.channel.run(
                command: .init { command.encode(to: &$0, database: database, labels: labels) },
                by: deadline)
        }
        catch let error
        {
            self.reuse = false
            throw error
        }
        if  let message:MongoWire.Message<ByteBufferView>
        {
            return try .init(message: message)
        }
        else
        {
            throw MongoChannel.TimeoutError.init()
        }
    }
}
