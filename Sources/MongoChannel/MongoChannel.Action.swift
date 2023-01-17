import BSON
import MongoWire
import NIOCore

extension MongoChannel
{
    public
    enum Action
    {
        case interrupt
        case timeout
        case request(BSON.Fields,
            CheckedContinuation<MongoWire.Message<ByteBufferView>, any Error>)
    }
}
