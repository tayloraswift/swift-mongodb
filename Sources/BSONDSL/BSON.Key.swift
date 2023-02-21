import BSON

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
    public
    init(_ codingKey:CodingKey)
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
