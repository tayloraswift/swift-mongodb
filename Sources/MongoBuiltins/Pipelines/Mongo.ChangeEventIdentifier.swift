import BSON

extension Mongo
{
    @frozen public
    struct ChangeEventIdentifier:RawRepresentable, Sendable
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
extension Mongo.ChangeEventIdentifier:Equatable
{
    @inlinable public
    static func == (a:Self, b:Self) -> Bool { a.rawValue.bytes == b.rawValue.bytes }
}
extension Mongo.ChangeEventIdentifier:BSONDecodable, BSONEncodable
{
}
