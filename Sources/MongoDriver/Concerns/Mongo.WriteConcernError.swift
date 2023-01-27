import BSONSchema

extension Mongo
{
    @frozen public
    struct WriteConcernError:Error, Sendable
    {
        public
        let code:Int32
        public
        let message:String

        public
        let details:
        (
            writeConcernProvenance:WriteConcernProvenance,
            writeConcern:WriteConcern
        )?

        @inlinable public
        init(code:Int32,
            message:String,
            details:
            (
                writeConcernProvenance:WriteConcernProvenance,
                writeConcern:WriteConcern
            )? = nil)
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
extension Mongo.WriteConcernError:BSONDictionaryDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.Dictionary<Bytes>) throws
    {
        let details:(Mongo.WriteConcernProvenance, Mongo.WriteConcern)? =
            try bson["errInfo"]?.decode(as: BSON.Dictionary<Bytes.SubSequence>.self)
        {
            try $0["writeConcern"].decode(as: BSON.Dictionary<Bytes.SubSequence>.self)
            {
                (
                    try $0["provenance"].decode(to: Mongo.WriteConcernProvenance.self),
                    try .init(bson: $0)
                )
            }
        }
        self.init(code: try bson["code"].decode(to: Int32.self),
            message: try bson["errmsg"].decode(to: String.self),
            details: details)
    }
}
extension Mongo.WriteConcernError:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["errmsg"] = self.message
        bson["code"] = self.code
        bson["errInfo"] = self.details.map
        {
            let (writeConcernProvenance, writeConcern):
            (
                Mongo.WriteConcernProvenance,
                Mongo.WriteConcern
            ) = $0
            return .init
            {
                $0["writeConcern"] = .init
                {
                    writeConcern.encode(to: &$0)
                    $0["provenance"] = writeConcernProvenance
                }
            }
        }
    }
}
