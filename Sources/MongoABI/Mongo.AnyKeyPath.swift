import BSON

extension Mongo
{
    @frozen public
    struct AnyKeyPath:Equatable, Hashable, Sendable
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
extension Mongo.AnyKeyPath:RawRepresentable
{
    /// See ``rawValue``.
    @inlinable public
    init(rawValue:String)
    {
        self.init(stem: .init(rawValue: rawValue))
    }

    /// The key path stem, which is the entire key path minus the leading `$` character that
    /// would normally appear when encoding the key path in an expression.
    @inlinable public
    var rawValue:String { self.stem.rawValue }
}
extension Mongo.AnyKeyPath:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(rawValue: stringLiteral)
    }
}
extension Mongo.AnyKeyPath:CustomStringConvertible
{
    @inlinable public
    var description:String { "$\(self.stem)" }
}
extension Mongo.AnyKeyPath:BSONStringEncodable
{
}
extension Mongo.AnyKeyPath
{
    /// Creates a key path by joining two key paths with a `.` character.
    @inlinable public static
    func / (self:Self, next:Self) -> Self
    {
        .init(rawValue: "\(self.stem).\(next.stem)")
    }
}
