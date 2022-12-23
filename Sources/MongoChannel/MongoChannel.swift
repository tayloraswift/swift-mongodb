import BSONDecoding
import Heartbeats
import MongoWire
import NIOCore

/// @import(NIOCore)
/// A connection to a `mongod`/`mongos` host. This type is an API wrapper around
/// an NIO ``Channel``.
///
/// > Warning: This type is not managed! If you are storing instances of this type, 
/// there must be code elsewhere responsible for closing the wrapped NIO ``Channel``!
public
struct MongoChannel:Sendable
{
    @usableFromInline
    let channel:any Channel
    public
    let heart:Heart

    private
    init(channel:any Channel, heart:Heart)
    {
        self.channel = channel
        self.heart = heart
    }

    /// Closes the NIO ``Channel`` wrapped by this instance, which will
    /// also (indirectly) stop its attached heartbeat via the channel’s
    /// close-future.
    public
    func close()
    {
        self.channel.close(mode: .all, promise: nil)
    }
}
extension MongoChannel
{
    /// Creates a instance of this type wrapping the given NIO ``Channel``,
    /// and registers a callback on its close-future stopping the given
    /// heartbeat.
    public
    init(channel:any Channel, attaching heart:Heart)
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
        self.init(channel: channel, heart: heart)
    }
}
extension MongoChannel
{
    public static
    func === (lhs:Self, rhs:Self) -> Bool
    {
        lhs.channel === rhs.channel
    }
    public static
    func !== (lhs:Self, rhs:Self) -> Bool
    {
        lhs.channel !== rhs.channel
    }
}
extension MongoChannel
{
    /// Sends the given command document over this connection, unchanged, and
    /// awaits its message-response.
    @inlinable public
    func send(command:__owned BSON.Fields) async throws -> MongoWire.Message<ByteBufferView>
    {
        try await withCheckedThrowingContinuation
        {
            (continuation:CheckedContinuation<MongoWire.Message<ByteBufferView>, any Error>) in

            self.channel.writeAndFlush((command, continuation), promise: nil)
        }
    }
}
