import MongoWire
import NIOCore

extension Mongo.WireMessageRouter
{
    enum State
    {
        case perished((any Error)?)
        case awaiting(EventLoopPromise<MongoWire.Message<ByteBufferView>>?)
    }
}
