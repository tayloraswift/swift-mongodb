import MongoWire
import NIOCore

extension MongoIO
{
    public
    enum Action
    {
        case request(MongoWire.Message<[UInt8]>.Sections, CheckedContinuation<
            Result<MongoWire.Message<ByteBufferView>, ChannelError>,
            Never>)
        case cancel(CancellationError)
    }
}
