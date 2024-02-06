extension BSON
{
    /// A BSON field key. This type wraps a ``rawValue`` that is
    /// guaranteed to never contain null bytes. (Null bytes in a
    /// BSON field key can be exploited to perform SQL injection.)
    @frozen public
    struct Key:Hashable, RawRepresentable, Sendable
    {
        public
        let rawValue:String

        @inlinable public
        init(rawValue:String)
        {
            precondition(!rawValue.utf8.contains(0))
            self.rawValue = rawValue
        }
    }
}
extension BSON.Key
{
    @inlinable public
    init(index:Int)
    {
        self.init(rawValue: index.description)
    }
    @inlinable public
    init(_ other:some RawRepresentable<String>)
    {
        self.init(rawValue: other.rawValue)
    }
    public
    init(_ codingKey:some CodingKey)
    {
        self.init(rawValue: codingKey.stringValue)
    }
}
extension BSON.Key:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.rawValue < rhs.rawValue
    }
}
extension BSON.Key:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
extension BSON.Key:ExpressibleByStringLiteral, ExpressibleByStringInterpolation
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(rawValue: stringLiteral)
    }
}
extension BSON.Key
{
    /// Creates a key (path) by joining two keys with a `.` character.
    ///
    /// Some applications that use BSON, such as MongoDB, consider `.`
    /// characters significant.
    @available(*, deprecated, message: "Prefer 'Mongo.AnyKeyPath' instead.")
    @inlinable public static
    func / (self:Self, next:Self) -> Self
    {
        .init(rawValue: "\(self).\(next)")
    }
}
