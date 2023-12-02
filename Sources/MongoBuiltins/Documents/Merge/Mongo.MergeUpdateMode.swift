import BSON

extension Mongo
{
    @frozen public
    enum MergeUpdateMode:String, Hashable, Sendable
    {
        case replace
        case keepExisting
        case merge
        case fail
    }
}
extension Mongo.MergeUpdateMode:BSONDecodable, BSONEncodable
{
}
