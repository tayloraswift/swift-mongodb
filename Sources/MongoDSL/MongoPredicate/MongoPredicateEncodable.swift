import BSONEncoding

//  This is needed to prevent aggregation expression API from being
//  available when encoding predicate documents without `$expr`.
//
//  Not having this would be dangerous, because operators like `$mod`
//  exist in both DSLs, but have similar signatures with different
//  semantics.
public
protocol MongoPredicateEncodable:BSONEncodable
{
}

extension Never:MongoPredicateEncodable
{
}
extension Bool:MongoPredicateEncodable
{
}
extension Int32:MongoPredicateEncodable
{
}
extension Int64:MongoPredicateEncodable
{
}
//  We need this, both for general ergonomics, and because without it
//  all integer literals will be inferred to be of type ``Double``.
extension Int:MongoPredicateEncodable
{
}
extension Double:MongoPredicateEncodable
{
}
extension Unicode.Scalar:MongoPredicateEncodable
{
}
extension Character:MongoPredicateEncodable
{
}
extension String:MongoPredicateEncodable
{
}
extension Substring:MongoPredicateEncodable
{
}
extension BSON.Decimal128:MongoPredicateEncodable
{
}
extension BSON.Identifier:MongoPredicateEncodable
{
}
extension BSON.Max:MongoPredicateEncodable
{
}
extension BSON.Millisecond:MongoPredicateEncodable
{
}
extension BSON.Min:MongoPredicateEncodable
{
}
extension BSON.Regex:MongoPredicateEncodable
{
}

extension Set:MongoPredicateEncodable where Element:MongoPredicateEncodable
{
}
extension Array:MongoPredicateEncodable where Element:MongoPredicateEncodable
{
}
extension Optional:MongoPredicateEncodable where Wrapped:MongoPredicateEncodable
{
}
extension [String: Never]:MongoPredicateEncodable
{
}
