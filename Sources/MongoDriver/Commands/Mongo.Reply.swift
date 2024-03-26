import BSON
import MongoWire

extension Mongo
{
    @frozen public
    struct Reply
    {
        @usableFromInline internal
        let result:Result<BSON.DocumentDecoder<BSON.Key>, any Error>

        @usableFromInline internal
        let operationTime:BSON.Timestamp?
        @usableFromInline internal
        let clusterTime:ClusterTime?

        init(result:Result<BSON.DocumentDecoder<BSON.Key>, any Error>,
            operationTime:BSON.Timestamp?,
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
        case .success: true
        case .failure: false
        }
    }

    @inlinable internal
    func callAsFunction() throws -> BSON.DocumentDecoder<BSON.Key>
    {
        try self.result.get()
    }
}
extension Mongo.Reply
{
    public
    init(message:Mongo.WireMessage) throws
    {
        let bson:BSON.DocumentDecoder<BSON.Key> = try .init(
            parsing: message.sections.body)
        let status:Status = try bson["ok"].decode(
            to: Status.self)

        let operationTime:BSON.Timestamp? = try bson["operationTime"]?.decode(
            to: BSON.Timestamp.self)
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

        if  let code:Int32 = try bson["code"]?.decode()
        {
            self.init(result: .failure(Mongo.ServerError.init(
                        Mongo.ServerError.Code.init(rawValue: code),
                        message: message)),
                operationTime: operationTime,
                clusterTime: clusterTime)
        }
        else
        {
            self.init(result: .failure(Mongo.ReplyError.uncoded(message: message)),
                operationTime: operationTime,
                clusterTime: clusterTime)
            return
        }
    }
}
