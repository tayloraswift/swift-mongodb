import MongoWire
import NIOCore

extension Mongo
{
    public
    enum WireAction
    {
        case request(MongoWire.Message<[UInt8]>.Sections,
            EventLoopPromise<MongoWire.Message<ByteBufferView>>)

        case cancel(throwing:any Error)
    }
}
