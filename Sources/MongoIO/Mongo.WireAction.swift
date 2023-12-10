import MongoWire
import NIOCore

extension Mongo
{
    public
    enum WireAction
    {
        case request(Mongo.WireMessage<[UInt8]>.Sections,
            EventLoopPromise<Mongo.WireMessage<ByteBufferView>>)

        case cancel(throwing:any Error)
    }
}
