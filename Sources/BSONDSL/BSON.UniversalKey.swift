import BSON

extension BSON
{
    @frozen public
    struct UniversalKey:Hashable, RawRepresentable
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
extension BSON.UniversalKey
{
    public
    init(_ codingKey:CodingKey)
    {
        self.init(rawValue: codingKey.stringValue)
    }
}
extension BSON.UniversalKey:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
extension BSON.UniversalKey:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(rawValue: stringLiteral)
    }
}
