import BSON
import BSONDSL
import MongoWire
import NIOCore

extension MongoChannel
{
    public
    enum Action
    {
        case interrupt
        case timeout
        case request(MongoWire.Message<[UInt8]>.Sections,
            CheckedContinuation<MongoWire.Message<ByteBufferView>, any Error>)
    }
}
