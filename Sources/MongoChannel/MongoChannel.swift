import BSON
import Heartbeats
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
    /// Wraps the provided NIO ``Channel`` and attaches the given heartbeat
    /// controller, which will terminate the associated stream of heartbeats
    /// when the channel closes.
    public
    init(_ channel:any Channel, attaching heart:__shared Heart)
    {
        channel.closeFuture.whenComplete
        {
            //  when the checker task is cancelled, it will also close the
            //  connection again, which will be a no-op.
            switch $0
            {
            case .success(()):
                heart.stop()
            case .failure(let error):
                heart.stop(throwing: error)
            }
        }
        self.init(channel)
    }
    /// Closes this channel, returning when the channel has been closed.
    ///
    /// If a heartbeat controller was attached to this channel, this method
    /// will also terminate the associated stream of heartbeats.
    public
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
    public
    func interrupt()
    {
        self.channel.writeAndFlush(Action.interrupt, promise: nil)
    }

    @usableFromInline
    func timeout(by deadline:ContinuousClock.Instant) async throws
    {
        try await Task.sleep(until: deadline, clock: .continuous)
        self.channel.writeAndFlush(Action.timeout, promise: nil)
    }
}
extension MongoChannel
{

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
    @inlinable public
    func run(command:__owned BSON.Fields,
        by deadline:ContinuousClock.Instant) async throws -> MongoWire.Message<ByteBufferView>
    {
        guard .now <= deadline
        else
        {
            throw TimeoutError.init()
        }

        async
        let _:Void = self.timeout(by: deadline)

        return try await withCheckedThrowingContinuation
        {
            (continuation:CheckedContinuation<MongoWire.Message<ByteBufferView>, any Error>) in

            self.channel.writeAndFlush(Action.request(command, continuation), promise: nil)
        }
    }
}
