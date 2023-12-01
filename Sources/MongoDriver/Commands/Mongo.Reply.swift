import BSONDecoding
import MongoWire
import NIOCore

extension Mongo
{
    @frozen public
    struct Reply
    {
        @usableFromInline internal
        let result:Result<BSON.DocumentDecoder<BSON.Key, ByteBufferView>, any Error>

        @usableFromInline internal
        let operationTime:Timestamp?
        @usableFromInline internal
        let clusterTime:ClusterTime?

        init(result:Result<BSON.DocumentDecoder<BSON.Key, ByteBufferView>, any Error>,
            operationTime:Timestamp?,
            clusterTime:ClusterTime?)
        {
            self.result = result
            self.operationTime = operationTime
            self.clusterTime = clusterTime
        }
    }
}
extension Mongo.Reply
{
    var ok:Bool
    {
        switch self.result
        {
        case .success: return true
        case .failure: return false
        }
    }

    @inlinable internal
    func callAsFunction() throws -> BSON.DocumentDecoder<BSON.Key, ByteBufferView>
    {
        try self.result.get()
    }
}
extension Mongo.Reply
{
    public
    init(message:MongoWire.Message<ByteBufferView>) throws
    {
        let bson:BSON.DocumentDecoder<BSON.Key, ByteBufferView> = try .init(
            parsing: message.sections.body)
        let status:Status = try bson["ok"].decode(
            to: Status.self)

        let operationTime:Mongo.Timestamp? = try bson["operationTime"]?.decode(
            to: Mongo.Timestamp.self)
        let clusterTime:Mongo.ClusterTime? = try bson["$clusterTime"]?.decode(
            to: Mongo.ClusterTime.self)

        if  status.ok
        {
            self.init(result: .success(bson),
                operationTime: operationTime,
                clusterTime: clusterTime)
            return
        }

        let message:String = try bson["errmsg"]?.decode(to: String.self) ?? ""

        guard
        let code:Int32 = try bson["code"]?.decode()
        else
        {
            self.init(result: .failure(Mongo.ReplyError.uncoded(message: message)),
                operationTime: operationTime,
                clusterTime: clusterTime)
            return
        }

        if  code == 26
        {
            self.init(result: .failure(Mongo.NamespaceError.init()),
                operationTime: operationTime,
                clusterTime: clusterTime)
        }
        else
        {
            self.init(result: .failure(Mongo.ServerError.init(
                        Mongo.ServerError.Code.init(rawValue: code),
                        message: message)),
                operationTime: operationTime,
                clusterTime: clusterTime)
        }
    }
}
