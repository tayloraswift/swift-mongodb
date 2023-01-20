import BSONDecoding
import MongoWire
import NIOCore

extension Mongo
{
    @frozen public
    struct Reply
    {
        @usableFromInline
        let result:Result<BSON.Dictionary<ByteBufferView>, Mongo.ServerError>

        @usableFromInline
        let operationTime:Instant?
        @usableFromInline
        let clusterTime:NotarizedTime?

        init(result:Result<BSON.Dictionary<ByteBufferView>, Mongo.ServerError>,
            operationTime:Instant?,
            clusterTime:NotarizedTime?)
        {
            self.result = result
            self.operationTime = operationTime
            self.clusterTime = clusterTime
        }
    }
}
extension Mongo.Reply
{
    public
    init(message:MongoWire.Message<ByteBufferView>) throws
    {
        let dictionary:BSON.Dictionary<ByteBufferView> = try .init(
            fields: try message.sections.body.parse())
        let status:Status = try dictionary["ok"].decode(
            to: Status.self)

        let operationTime:Mongo.Instant? = try dictionary["operationTime"]?.decode(
            to: Mongo.Instant.self)
        let clusterTime:Mongo.NotarizedTime? = try dictionary["$clusterTime"]?.decode(
            to: Mongo.NotarizedTime.self)
        
        if  status.ok
        {
            self.init(result: .success(dictionary),
                operationTime: operationTime,
                clusterTime: clusterTime)
        }
        else
        {
            self.init(result: .failure(.init(
                    message: try dictionary["errmsg"]?.decode(to: String.self) ?? "",
                    code: try dictionary["code"]?.decode(to: Int32.self))),
                operationTime: operationTime,
                clusterTime: clusterTime)
        }
    }
}
