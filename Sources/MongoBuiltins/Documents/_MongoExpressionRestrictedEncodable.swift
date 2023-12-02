import BSON

/// This protocol provides diagnostics to help you avoid common mistakes, such as
/// using keypaths or expression variables at the top-level of a ``Mongo.PredicateDocument``.
public
protocol _MongoExpressionRestrictedEncodable:BSONEncodable
{
}
