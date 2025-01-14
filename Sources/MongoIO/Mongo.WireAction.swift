import MongoWire
import NIOCore

extension Mongo
{
    public
    enum WireAction:Sendable
    {
        case request(Mongo.WireMessage.Sections, EventLoopPromise<Mongo.WireMessage>)
        case cancel(throwing:any Error)
    }
}
