import BSONEncoding

public
protocol MongoExpressionVariable:BSONStringEncodable, CustomStringConvertible
{
    init(name:String)
    var name:String { get }
}
extension MongoExpressionVariable where Self:CustomStringConvertible
{
    /// Returns this variable’s ``name`` prefixed with two dollar signs.
    @inlinable public
    var description:String { "$$\(self.name)" }
}
extension MongoExpressionVariable where Self:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(name: stringLiteral)
    }
}
extension MongoExpressionVariable
{
    /// Returns a key path application expression on this variable
    /// with the provided key path.
    @inlinable public
    subscript(key:BSON.Key) -> String
    {
        "\(self).\(key)"
    }
}
