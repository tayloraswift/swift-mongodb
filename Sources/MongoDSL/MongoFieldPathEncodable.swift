import BSONEncoding

public
protocol MongoFieldPathEncodable:MongoExpressionEncodable
{
}
extension Unicode.Scalar:MongoFieldPathEncodable
{
}
extension Character:MongoFieldPathEncodable
{
}
extension Substring:MongoFieldPathEncodable
{
}
extension String:MongoFieldPathEncodable
{
}
extension StaticString:MongoFieldPathEncodable
{
}
