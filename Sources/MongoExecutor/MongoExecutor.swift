import NIOCore
import MongoIO
import MongoWire

public
protocol MongoExecutor
{
    var channel:any Channel { get }
}
extension MongoExecutor
{
    /// Sends the given command document over this connection, unchanged, and awaits its
    /// message-response.
    ///
    /// If the task the caller of this function is running on gets cancelled, this function will
    /// close ``channel`` and return failure. This function does not check for cancellation
    /// before sending the request; it is the responsibility of the caller to check for
    /// cancellation.
    ///
    /// If the deadline passes without a reply from the server, this function will close
    /// ``channel`` and throw a ``Mongo.WireTimeoutError``. This function does not check if the
    /// deadline has already passed before sending the request; it is the responsibility of the
    /// caller to check if the deadline is sensible.
    public
    func request(
        sections:__owned MongoWire.Message<[UInt8]>.Sections,
        deadline:ContinuousClock.Instant) async throws -> MongoWire.Message<ByteBufferView>
    {
        try await Self.request(self.channel, sections: sections, deadline: deadline)
    }

    /// Interrupts this channel, forcing it to close (asynchronously), but
    /// returning without waiting for the channel to complete its shutdown
    /// procedure.
    public
    func crosscancel(throwing error:any Error)
    {
        Self.crosscancel(self.channel, throwing: error)
    }

    /// Closes this channel, returning when the channel has been closed.
    public
    func close() async
    {
        await Self.close(self.channel)
    }
}
extension MongoExecutor
{
    private static
    func timeout(_ channel:any Channel, by deadline:ContinuousClock.Instant) async throws
    {
        try await Task.sleep(until: deadline, clock: .continuous)
        channel.writeAndFlush(Mongo.WireAction.cancel(throwing: Mongo.WireTimeoutError.init()),
            promise: nil)
    }
    /// Sends the given command document over this connection, unchanged, and
    /// awaits its message-response.
    ///
    /// If the deadline passes without a reply from the server, the channel
    /// will be closed. This will happen even if the deadline has already passed;
    /// therefore it is the responsibility of the calling code to check if the
    /// deadline is sensible.
    private static
    func request(_ channel:any Channel,
        sections:__owned MongoWire.Message<[UInt8]>.Sections,
        deadline:ContinuousClock.Instant) async throws -> MongoWire.Message<ByteBufferView>
    {
        async
        let _:Void = Self.timeout(channel, by: deadline)

        return try await withTaskCancellationHandler
        {
            let promise:EventLoopPromise<MongoWire.Message<ByteBufferView>> =
                channel.eventLoop.makePromise()

            channel.writeAndFlush(Mongo.WireAction.request(sections, promise)).whenFailure
            {
                // don’t leak the promise!
                promise.fail(Mongo.NetworkError.init(underlying: $0))
            }

            return try await promise.futureResult.get()
        }
        onCancel:
        {
            channel.writeAndFlush(Mongo.WireAction.cancel(throwing: CancellationError.init()),
                promise: nil)
        }
    }
}
extension MongoExecutor
{
    @usableFromInline internal static
    func crosscancel(_ channel:any Channel, throwing error:any Error)
    {
        channel.writeAndFlush(Mongo.WireAction.cancel(throwing: Mongo.NetworkError.init(
                underlying: error,
                provenance: .crosscancellation)),
            promise: nil)
    }

    @usableFromInline internal static
    func close(_ channel:any Channel) async
    {
        try? await channel.close(mode: .all)
    }
}
