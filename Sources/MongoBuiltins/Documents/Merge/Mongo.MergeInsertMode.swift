import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    enum MergeInsertMode:String, Hashable, Sendable
    {
        case insert
        case discard
        case fail
    }
}
extension Mongo.MergeInsertMode:BSONDecodable, BSONEncodable
{
}
