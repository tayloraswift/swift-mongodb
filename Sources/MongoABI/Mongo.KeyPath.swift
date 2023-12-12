import BSON

extension Mongo
{
    @frozen public
    struct KeyPath:Equatable, Hashable, Sendable
    {
        public
        var stem:BSON.Key

        @inlinable internal
        init(stem:BSON.Key)
        {
            self.stem = stem
        }
    }
}
extension Mongo.KeyPath
{
    @inlinable public
    init(rawValue:String)
    {
        self.init(stem: .init(rawValue: rawValue))
    }

    @inlinable public
    var rawValue:String { self.stem.rawValue }
}
extension Mongo.KeyPath:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(rawValue: stringLiteral)
    }
}
extension Mongo.KeyPath:CustomStringConvertible
{
    @inlinable public
    var description:String { "$\(self.stem)" }
}
extension Mongo.KeyPath:BSONStringEncodable
{
}
extension Mongo.KeyPath
{
    /// Creates a key path by joining two key paths with a `.` character.
    @inlinable public static
    func / (self:Self, next:Self) -> Self
    {
        .init(rawValue: "\(self.stem).\(next.stem)")
    }
}
