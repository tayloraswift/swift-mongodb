import BSONDecoding
import MongoWire
import NIOCore

extension Mongo
{
    @frozen public
    struct Reply
    {
        @usableFromInline
        let result:Result<BSON.Dictionary<ByteBufferView>, ServerError>

        @usableFromInline
        let operationTime:Mongo.Instant?
        @usableFromInline
        let clusterTime:Mongo.Instant?

        init(result:Result<BSON.Dictionary<ByteBufferView>, ServerError>,
            operationTime:Mongo.Instant?,
            clusterTime:Mongo.Instant?)
        {
            self.result = result
            self.operationTime = operationTime
            self.clusterTime = clusterTime
        }
    }
}
extension Mongo.Reply
{
    init(message:MongoWire.Message<ByteBufferView>) throws
    {
        let dictionary:BSON.Dictionary<ByteBufferView> = try .init(
            fields: try message.sections.body.parse())
        let ok:Bool = try dictionary["ok"].decode
        {
            switch $0
            {
            case .bool(true), .int32(1), .int64(1), .double(1.0):
                return true
            case .bool(false), .int32(0), .int64(0), .double(0.0):
                return false
            case let unsupported:
                throw Mongo.ReplyError.invalidStatusType(unsupported.type)
            }
        }

        let operationTime:Mongo.Instant? = try dictionary["operationTime"]?.decode(
            to: Mongo.Instant.self)
        let clusterTime:Mongo.Instant? = try dictionary["$clusterTime"]?.decode(
            to: Mongo.Instant.self)
        
        if ok
        {
            self.init(result: .success(dictionary),
                operationTime: operationTime,
                clusterTime: clusterTime)
        }
        else
        {
            self.init(result: .failure(.init(
                    message: try dictionary["errmsg"]?.decode(to: String.self) ?? "")),
                operationTime: operationTime,
                clusterTime: clusterTime)
        }
    }
}
