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
    /// @import(MongoIO)
    /// Sends the given command document over this connection, unchanged, and
    /// awaits its message-response.
    ///
    /// If the task the caller of this function is running on gets cancelled,
    /// this function will close ``channel`` and return failure. This function
    /// does not check for cancellation before sending the request; it is the
    /// responsibility of the caller to check for cancellation.
    ///
    /// If the deadline passes without a reply from the server, this function
    /// will close ``channel`` and return failure. This function does not check
    /// if the deadline has already passed before sending the request; it is
    /// the responsibility of the caller to check if the deadline is sensible.
    public
    func request(sections:__owned MongoWire.Message<[UInt8]>.Sections,
        deadline:ContinuousClock.Instant)
        async -> Result<MongoWire.Message<ByteBufferView>, MongoIO.ChannelError>
    {
        await Self.request(self.channel, sections: sections, deadline: deadline)
    }

    /// Interrupts this channel, forcing it to close (asynchronously), but
    /// returning without waiting for the channel to complete its shutdown
    /// procedure.
    public
    func cancel()
    {
        Self.cancel(self.channel)
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
        Self.cancel(channel, because: .timeout)
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
        deadline:ContinuousClock.Instant)
        async -> Result<MongoWire.Message<ByteBufferView>, MongoIO.ChannelError>
    {
        #if compiler(<5.8)
        async
        let __:Void = Self.timeout(channel, by: deadline)
        #else
        async
        let _:Void = Self.timeout(channel, by: deadline)
        #endif

        return await withTaskCancellationHandler
        {
            await withCheckedContinuation
            {
                (continuation:CheckedContinuation<
                    Result<MongoWire.Message<ByteBufferView>, MongoIO.ChannelError>,
                    Never>) in

                channel.writeAndFlush(MongoIO.Action.request(sections, continuation))
                    .whenComplete
                {
                    // don’t leak the continuation!
                    if case .failure(let error) = $0
                    {
                        continuation.resume(returning: .failure(.network(error, sent: false)))
                    }
                }
            }
        }
        onCancel:
        {
            Self.cancel(channel)
        }
    }

}
extension MongoExecutor
{
    @usableFromInline internal static
    func cancel(_ channel:any Channel, because reason:MongoIO.CancellationError = .cancel)
    {
        channel.writeAndFlush(MongoIO.Action.cancel(reason), promise: nil)
    }

    @usableFromInline internal static
    func close(_ channel:any Channel) async
    {
        try? await channel.close(mode: .all)
    }
}
