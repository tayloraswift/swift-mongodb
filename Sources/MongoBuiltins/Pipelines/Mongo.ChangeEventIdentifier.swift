import BSON

extension Mongo
{
    @frozen public
    struct ChangeEventIdentifier:RawRepresentable, BSONDecodable, BSONEncodable, Sendable
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
