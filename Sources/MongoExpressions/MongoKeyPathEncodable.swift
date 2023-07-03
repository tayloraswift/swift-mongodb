import BSONEncoding

//  TODO: do we really need this?
public
protocol MongoKeyPathEncodable:BSONEncodable
{
}
extension Unicode.Scalar:MongoKeyPathEncodable
{
}
extension Character:MongoKeyPathEncodable
{
}
extension Substring:MongoKeyPathEncodable
{
}
extension String:MongoKeyPathEncodable
{
}
extension StaticString:MongoKeyPathEncodable
{
}
