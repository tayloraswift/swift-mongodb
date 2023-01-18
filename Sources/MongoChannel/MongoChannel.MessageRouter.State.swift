import MongoWire
import NIOCore

extension MongoChannel.MessageRouter
{
    enum State
    {
        case awaiting(CheckedContinuation<MongoWire.Message<ByteBufferView>, any Error>?)
        case perished
    }
}
