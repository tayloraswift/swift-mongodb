import MongoWire
import NIOCore

extension MongoChannel.MessageRouter
{
    enum State
    {
        case perished
        case awaiting(CheckedContinuation<
            Result<MongoWire.Message<ByteBufferView>, MongoChannel.ExecutionError>,
            Never>?)
    }
}
