import BSON

extension Mongo
{
    @frozen public
    enum WriteConcernProvenance:String, Hashable, Sendable
    {
        case clientSupplied
        case customDefault
        case getLastErrorDefaults
        case implicitDefault
    }
}
extension Mongo.WriteConcernProvenance:BSONDecodable, BSONEncodable
{
}
