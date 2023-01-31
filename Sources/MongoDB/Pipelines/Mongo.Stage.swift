import BSONEncoding
import BSONDecoding

extension Mongo
{
    @frozen public
    struct Stage:Sendable
    {
        public
        let encoded:BSON.Fields
        // case bucket         (MongoExpression.Document)
        // case bucketAuto     (MongoExpression.Document)
        // case changeStream   (MongoExpression.Document)
        // case collectionStats(MongoExpression.Document)
        // case count          (String)
        // case densify        (MongoExpression.Document)
        // case documents      (MongoExpression)
        // case facet          (MongoExpression.Document)
        // case fill           (MongoExpression.Document)
        // case geoNear        (MongoExpression.Document)
        // case graphLookup    (MongoExpression.Document)
        // case group          (MongoExpression.Document)
        // case indexStats
        // case limit          (Int)
        // case listSessions   (MongoExpression.Document)
        // case lookup         (MongoExpression.Document)
        // case match          (MongoQuery.Document)
        // case planCacheStats
        // case project        (MongoProjection.Document)
        // case redact         (MongoExpression)
        // case replaceRoot    (MongoExpression.Document)
        // case sample         (MongoExpression.Document)
        // case set            (MongoExpression.Document)
        // case setWindowFields(MongoExpression.Document)
        // case skip           (Int)
        // case sort           (MongoExpression.Document)
        // case sortByCount    (MongoExpression)
        // case union     (with:Collection, [Stage] = [])
        // case unset          ([String])
        @inlinable public
        init(encoded:BSON.Fields)
        {
            self.encoded = encoded
        }
    }
}
extension Mongo.Stage
{
    @inlinable public
    init(_ name:String, value:some BSONEncodable)
    {
        self.init(encoded: .init
        {
            $0[name] = value
        })
    }
    @inlinable public
    init<DSL>(_ name:String,
        with populate:(inout DSL) throws -> ()) rethrows where DSL:BSONDSL & BSONEncodable
    {
        self.init(name, value: try DSL.init(with: populate))
    }
}
extension Mongo.Stage:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        self.encoded.encode(to: &field)
    }
}
extension Mongo.Stage
{
    @available(*, unavailable, renamed: "set(_:)")
    public static
    func addFields(
        _ populate:(inout MongoExpression.Document) throws -> ()) rethrows -> Self
    {
        try .set(populate)
    }
    @available(*, unavailable, renamed: "collectionStats(_:)")
    public static
    func collStats(
        _ populate:(inout MongoExpression.Document) throws -> ()) rethrows -> Self
    {
        try .collectionStats(populate)
    }
    @available(*, unavailable, renamed: "union(with:_:)")
    public static
    func unionWith(_ other:Mongo.Collection, pipeline:[Self] = []) -> Self
    {
        .union(with: other, pipeline: pipeline)
    }
}
extension Mongo.Stage
{
    @inlinable public static
    func bucket(_ populate:(inout MongoQuery.Document) throws -> ()) rethrows -> Self
    {
        try .init("$match", with: populate)
    }

    @inlinable public static
    func match(_ populate:(inout MongoQuery.Document) throws -> ()) rethrows -> Self
    {
        try .init("$match", with: populate)
    }

    @inlinable public static
    func project(_ populate:(inout MongoProjection.Document) throws -> ()) rethrows -> Self
    {
        try .init("$project", with: populate)
    }

    @inlinable public static
    func collectionStats(
        _ populate:(inout MongoExpression.Document) throws -> ()) rethrows -> Self
    {
        try .init("$collStats", with: populate)
    }

    @inlinable public static
    func set(
        _ populate:(inout MongoExpression.Document) throws -> ()) rethrows -> Self
    {
        try .init("$set", with: populate)
    }
}
extension Mongo.Stage
{
    @inlinable public static
    func union(with other:Mongo.Collection, pipeline:[Self] = []) -> Self
    {
        pipeline.isEmpty ? .init("$unionWith", value: other) : .init("$unionWith")
        {
            (bson:inout BSON.Fields) in

            bson["coll"] = other
            bson["pipeline"] = pipeline
        }
    }
}
