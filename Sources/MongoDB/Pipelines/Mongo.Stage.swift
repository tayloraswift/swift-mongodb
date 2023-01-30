import BSONEncoding

extension Mongo
{
    public
    enum Stage:Sendable
    {
        case bucket         (MongoExpression.Document)
        case bucketAuto     (MongoExpression.Document)
        case changeStream   (MongoExpression.Document)
        case collectionStats(MongoExpression.Document)
        case count          (String)
        case densify        (MongoExpression.Document)
        case documents      (MongoExpression)
        case facet          (MongoExpression.Document)
        case fill           (MongoExpression.Document)
        case geoNear        (MongoExpression.Document)
        case graphLookup    (MongoExpression.Document)
        case group          (MongoExpression.Document)
        case indexStats
        case limit          (Int)
        case listSessions   (MongoExpression.Document)
        case lookup         (MongoExpression.Document)
        case match          (MongoQuery.Document)
        case planCacheStats
        case project        (MongoProjection.Document)
        case redact         (MongoExpression)
        case replaceRoot    (MongoExpression.Document)
        case sample         (MongoExpression.Document)
        case set            (MongoExpression.Document)
        case setWindowFields(MongoExpression.Document)
        case skip           (Int)
        case sort           (MongoExpression.Document)
        case sortByCount    (MongoExpression)
        case union     (with:Collection, [Stage] = [])
        case unset          ([String])
    }
}
extension Mongo.Stage
{
    @available(*, unavailable, renamed: "set(_:)")
    public static
    func addFields(_ fields:MongoExpression.Document) -> Self
    {
        .set(fields)
    }
    @available(*, unavailable, renamed: "collectionStats(_:)")
    public static
    func collStats(_ fields:MongoExpression.Document) -> Self
    {
        .collectionStats(fields)
    }
    @available(*, unavailable, renamed: "union(with:_:)")
    public static
    func unionWith(_ collection:Mongo.Collection, _ pipeline:[Mongo.Stage] = []) -> Self
    {
        .union(with: collection, pipeline)
    }
}
