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
extension Mongo.WriteConcernError
{
    @frozen public
    enum CodingKey:String
    {
        case code
        case errorDetails = "errInfo"
        case errorMessage = "errmsg"
        case writeConcern
    }
}
extension Mongo.WriteConcernError:BSONDecodable, BSONDocumentDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.DocumentDecoder<CodingKey, Bytes>) throws
    {
        self.init(code: try bson[.code].decode(to: Int32.self),
            message: try bson[.errorMessage].decode(to: String.self),
            details: try bson[.errorDetails]?.decode
            {
                try $0["writeConcern"].decode(to: Details.self)
            })
    }
}
extension Mongo.WriteConcernError:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.code] = self.code
        bson[.errorMessage] = self.message

        guard let details:Details = self.details
        else
        {
            return
        }

        bson[.errorDetails]
        {
            $0["writeConcern"] = details
        }
    }
}
