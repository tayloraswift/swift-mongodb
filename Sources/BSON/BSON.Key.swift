extension BSON
{
    @frozen public
    struct Key:Hashable, RawRepresentable, Sendable
    {
        public
        let rawValue:String

        @inlinable public
        init(rawValue:String)
        {
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
extension BSON.Key:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
extension BSON.Key:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(rawValue: stringLiteral)
    }
}
