import BSONDecoding
import BSONEncoding

extension Mongo
{
    public
    struct WriteConcernError:Error, Sendable
    {
        public
        let code:Int32
        public
        let message:String
        public
        let details:Details?

        public
        init(code:Int32, message:String, details:Details? = nil)
        {
            self.code = code
            self.message = message
            self.details = details
        }
    }
}
extension Mongo.WriteConcernError:Equatable
{
    @inlinable public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        guard   lhs.code == rhs.code,
                lhs.message == rhs.message
        else
        {
            return false
        }
        switch (lhs.details, rhs.details)
        {
        case (nil, nil):
            return true
        case (_?, nil), (nil, _?):
            return false
        case (let lhs?, let rhs?):
            return lhs == rhs
        }
    }
}
extension Mongo.WriteConcernError:BSONDecodable, BSONDictionaryDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.Dictionary<Bytes>) throws
    {
        self.init(code: try bson["code"].decode(to: Int32.self),
            message: try bson["errmsg"].decode(to: String.self),
            details: try bson["errInfo"]?.decode(as: BSON.Dictionary<Bytes.SubSequence>.self)
            {
                try $0["writeConcern"].decode(to: Details.self)
            })
    }
}
extension Mongo.WriteConcernError:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["code"] = self.code
        bson["errmsg"] = self.message
        bson["errInfo", elide: true] = .init
        {
            $0["writeConcern"] = self.details
        }
    }
}
