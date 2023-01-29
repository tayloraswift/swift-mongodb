import BSONEncoding

extension Mongo
{
    public
    enum Stage:Sendable
    {
        case bucket         (ExpressionDocument)
        case bucketAuto     (ExpressionDocument)
        case changeStream   (ExpressionDocument)
        case collectionStats(ExpressionDocument)
        case count          (String)
        case densify        (ExpressionDocument)
        case documents      (Expression)
        case facet          (ExpressionDocument)
        case fill           (ExpressionDocument)
        case geoNear        (ExpressionDocument)
        case graphLookup    (ExpressionDocument)
        case group          (ExpressionDocument)
        case indexStats
        case limit          (Int)
        case listSessions   (ExpressionDocument)
        case lookup         (ExpressionDocument)
        case match          (BSON.Fields)
        case planCacheStats
        case project        (BSON.Fields)
        case redact         (Expression)
        case replaceRoot    (ExpressionDocument)
        case sample         (ExpressionDocument)
        case set            (ExpressionDocument)
        case setWindowFields(ExpressionDocument)
        case skip           (Int)
        case sort           (ExpressionDocument)
        case sortByCount    (Expression)
        case union     (with:Collection, [Stage] = [])
        case unset          ([String])
    }
}
extension Mongo.Stage
{
    @available(*, unavailable, renamed: "set(_:)")
    public static
    func addFields(_ fields:Mongo.ExpressionDocument) -> Self
    {
        .set(fields)
    }
    @available(*, unavailable, renamed: "collectionStats(_:)")
    public static
    func collStats(_ fields:Mongo.ExpressionDocument) -> Self
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
