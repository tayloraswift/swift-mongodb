import BSON

extension Mongo
{
    @frozen public
    struct ChangeEventIdentifier:RawRepresentable, Equatable, Sendable
    {
        public
        var rawValue:BSON.Document

        @inlinable public
        init(rawValue:BSON.Document)
        {
            self.rawValue = rawValue
        }
    }
}
extension Mongo.ChangeEventIdentifier:BSONDecodable, BSONEncodable
{
}
