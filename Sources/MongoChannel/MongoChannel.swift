import BSON
import BSONDSL
import MongoWire
import NIOCore

/// @import(NIOCore)
/// A channel to a `mongod`/`mongos` host. This type is a thin wrapper around an
/// NIO ``Channel`` and provides no lifecycle management.
public
struct MongoChannel:Sendable
{
    @usableFromInline
    let channel:any Channel

    /// Wraps the provided NIO ``Channel`` without attaching any heartbeat
    /// controller.
    public
    init(_ channel:any Channel)
    {
        self.channel = channel
    }
}
extension MongoChannel
{
    /// Attaches the provided callback to the underlying NIO ``Channel``’s
    /// close-future.
    @inlinable public
    func whenClosed(run callback:@Sendable @escaping (Result<Void, any Error>) -> ())
    {
        channel.closeFuture.whenComplete(callback)
    }
    /// Closes this channel, returning when the channel has been closed.
    ///
    /// If a heartbeat controller was attached to this channel, this method
    /// will also terminate the associated stream of heartbeats.
    @inlinable public
    func close() async
    {
        try? await self.channel.close(mode: .all)
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
        self.channel.writeAndFlush(Action.interrupt, promise: nil)
    }

    @inlinable public
    func timeout(by deadline:ContinuousClock.Instant) async throws
    {
        try await Task.sleep(until: deadline, clock: .continuous)
        self.channel.writeAndFlush(Action.timeout, promise: nil)
    }
}
extension MongoChannel:Equatable
{
    @inlinable public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.channel === rhs.channel
    }
}
extension MongoChannel:Hashable
{
    @inlinable public
    func hash(into hasher:inout Hasher)
    {
        hasher.combine(ObjectIdentifier.init(self.channel))
    }
}

extension MongoChannel
{
    /// Sends the given command document over this connection, unchanged, and
    /// awaits its message-response.
    ///
    /// If the deadline passes without a reply from the server, the channel
    /// will be closed. This will happen even if the deadline has already passed;
    /// therefore it is the responsibility of the calling code to check if the
    /// deadline is sensible.
    @inlinable public
    func run(command:__owned MongoWire.Message<[UInt8]>.Sections,
        by deadline:ContinuousClock.Instant)
        async -> Result<MongoWire.Message<ByteBufferView>, ExecutionError>
    {
        async
        let _:Void = self.timeout(by: deadline)

        return await withCheckedContinuation
        {
            (continuation:CheckedContinuation<
                Result<MongoWire.Message<ByteBufferView>, ExecutionError>,
                Never>) in

            self.channel.writeAndFlush(Action.request(command, continuation)).whenComplete
            {
                // don’t leak the continuation!
                if case .failure(let error) = $0
                {
                    continuation.resume(returning: .failure(.network(error: .other(error))))
                }
            }
        }
    }
}
