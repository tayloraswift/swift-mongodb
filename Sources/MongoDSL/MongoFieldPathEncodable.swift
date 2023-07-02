import BSONEncoding

//  TODO: do we really need this?
public
protocol MongoFieldPathEncodable:BSONEncodable
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
