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
    /// Sends the given command document over this connection, unchanged, and
    /// awaits its message-response.
    ///
    /// If the deadline passes without a reply from the server, the channel
    /// will be closed. This will happen even if the deadline has already passed;
    /// therefore it is the responsibility of the calling code to check if the
    /// deadline is sensible.
    @inlinable public
    func request(deadline:ContinuousClock.Instant,
        message:__owned MongoWire.Message<[UInt8]>.Sections)
        async -> Result<MongoWire.Message<ByteBufferView>, MongoIO.ExecutionError>
    {
        await Self.request(self.channel, deadline: deadline, message: message)
    }

    /// Interrupts this channel, forcing it to close (asynchronously), but
    /// returning without waiting for the channel to complete its shutdown
    /// procedure.
    ///
    /// If a heartbeat controller was attached to this channel, this method
    /// will also terminate the associated stream of heartbeats.
    @inlinable public
    func interrupt()
    {
        Self.interrupt(self.channel)
    }

    /// Closes this channel, returning when the channel has been closed.
    @inlinable public
    func close() async
    {
        await Self.close(self.channel)
    }
}
extension MongoExecutor
{
    /// Sends the given command document over this connection, unchanged, and
    /// awaits its message-response.
    ///
    /// If the deadline passes without a reply from the server, the channel
    /// will be closed. This will happen even if the deadline has already passed;
    /// therefore it is the responsibility of the calling code to check if the
    /// deadline is sensible.
    @usableFromInline internal static
    func request(_ channel:any Channel, deadline:ContinuousClock.Instant,
        message:__owned MongoWire.Message<[UInt8]>.Sections)
        async -> Result<MongoWire.Message<ByteBufferView>, MongoIO.ExecutionError>
    {
        #if compiler(<5.8)
        async
        let __:Void = Self.timeout(channel, by: deadline)
        #else
        async
        let _:Void = Self.timeout(channel, by: deadline)
        #endif

        return await withCheckedContinuation
        {
            (continuation:CheckedContinuation<
                Result<MongoWire.Message<ByteBufferView>, MongoIO.ExecutionError>,
                Never>) in

            channel.writeAndFlush(MongoIO.Action.request(message, continuation))
                .whenComplete
            {
                // don’t leak the continuation!
                if case .failure(let error) = $0
                {
                    continuation.resume(returning: .failure(.network(error: .perished(error))))
                }
            }
        }
    }
    private static
    func timeout(_ channel:any Channel, by deadline:ContinuousClock.Instant) async throws
    {
        try await Task.sleep(until: deadline, clock: .continuous)
        channel.writeAndFlush(MongoIO.Action.timeout, promise: nil)
    }
}
extension MongoExecutor
{
    @usableFromInline internal static
    func interrupt(_ channel:any Channel)
    {
        channel.writeAndFlush(MongoIO.Action.interrupt, promise: nil)
    }

    @usableFromInline internal static
    func close(_ channel:any Channel) async
    {
        try? await channel.close(mode: .all)
    }
}
