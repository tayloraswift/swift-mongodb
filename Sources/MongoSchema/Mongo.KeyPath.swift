import BSON

extension Mongo
{
    @frozen public
    struct KeyPath:Equatable, Hashable, Sendable
    {
        public
        var stem:String

        @inlinable internal
        init(_ stem:String)
        {
            self.stem = stem
        }
    }
}
extension Mongo.KeyPath:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral stem:String)
    {
        self.init(stem)
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
        .init("\(self.stem).\(next.stem)")
    }
}
