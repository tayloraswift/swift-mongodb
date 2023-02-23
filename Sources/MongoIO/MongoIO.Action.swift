import MongoWire
import NIOCore

extension MongoIO
{
    public
    enum Action
    {
        case interrupt
        case timeout
        case request(MongoWire.Message<[UInt8]>.Sections, CheckedContinuation<
            Result<MongoWire.Message<ByteBufferView>, ExecutionError>,
            Never>)
    }
}
