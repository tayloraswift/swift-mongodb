import BSONEncoding

extension Mongo
{
    public
    enum Stage:Sendable
    {
        case bucket         (BSON.Fields)
        case bucketAuto     (BSON.Fields)
        case changeStream   (BSON.Fields)
        case collectionStats(BSON.Fields)
        case count          (String)
        case densify        (BSON.Fields)
        case documents      (Expression)
        case facet          (BSON.Fields)
        case fill           (BSON.Fields)
        case geoNear        (BSON.Fields)
        case graphLookup    (BSON.Fields)
        case group          (BSON.Fields)
        case indexStats
        case limit          (Int)
        case listSessions   (BSON.Fields)
        case lookup         (BSON.Fields)
        case match          (BSON.Fields)
        case planCacheStats
        case project        (BSON.Fields)
        case redact         (Expression)
        case replaceRoot    (BSON.Fields)
        case sample         (BSON.Fields)
        case set            (BSON.Fields)
        case setWindowFields(BSON.Fields)
        case skip           (Int)
        case sort           (BSON.Fields)
        case sortByCount    (Expression)
        case union     (with:Collection, [Stage] = [])
        case unset          ([String])
    }
}
extension Mongo.Stage
{
    @available(*, unavailable, renamed: "set(_:)")
    public static
    func addFields(_ fields:BSON.Fields) -> Self
    {
        .set(fields)
    }
    @available(*, unavailable, renamed: "collectionStats(_:)")
    public static
    func collStats(_ fields:BSON.Fields) -> Self
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
