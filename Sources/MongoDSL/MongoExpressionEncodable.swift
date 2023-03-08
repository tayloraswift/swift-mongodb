import BSONEncoding

public
protocol MongoExpressionEncodable:BSONFieldEncodable
{
}

extension Never:MongoExpressionEncodable
{
}
extension Bool:MongoExpressionEncodable
{
}
extension Int32:MongoExpressionEncodable
{
}
extension Int64:MongoExpressionEncodable
{
}
//  We need this, both for general ergonomics, and because without it
//  all integer literals will be inferred to be of type ``Double``.
extension Int:MongoExpressionEncodable
{
}
extension Double:MongoExpressionEncodable
{
}
extension Unicode.Scalar:MongoExpressionEncodable
{
}
extension Character:MongoExpressionEncodable
{
}
extension Substring:MongoExpressionEncodable
{
}
extension String:MongoExpressionEncodable
{
}
extension StaticString:MongoExpressionEncodable
{
}
extension BSON.Decimal128:MongoExpressionEncodable
{
}
extension BSON.Identifier:MongoExpressionEncodable
{
}
extension BSON.Max:MongoExpressionEncodable
{
}
extension BSON.Millisecond:MongoExpressionEncodable
{
}
extension BSON.Min:MongoExpressionEncodable
{
}
extension BSON.Regex:MongoExpressionEncodable
{
}

extension Set:MongoExpressionEncodable where Element:MongoExpressionEncodable
{
}
extension Array:MongoExpressionEncodable where Element:MongoExpressionEncodable
{
}
extension Optional:MongoExpressionEncodable where Wrapped:MongoExpressionEncodable
{
}
extension [String: Never]:MongoExpressionEncodable
{
}
