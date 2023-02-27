import MongoWire
import NIOCore

extension MongoIO.MessageRouter
{
    enum State
    {
        case perished
        case awaiting(CheckedContinuation<
            Result<MongoWire.Message<ByteBufferView>, MongoIO.ChannelError>,
            Never>?)
    }
}
