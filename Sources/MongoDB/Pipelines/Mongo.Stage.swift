import BSONEncoding
import BSONDecoding

extension Mongo
{
    @frozen public
    struct Stage:Sendable
    {
        public
        let encoded:BSON.Fields
        // case bucket         (MongoExpressionDSL)
        // case bucketAuto     (MongoExpressionDSL)
        // case changeStream   (MongoExpressionDSL)
        // case collectionStats(MongoExpressionDSL)
        // case count          (String)
        // case densify        (MongoExpressionDSL)
        // case documents      (MongoExpression)
        // case facet          (MongoExpressionDSL)
        // case fill           (MongoExpressionDSL)
        // case geoNear        (MongoExpressionDSL)
        // case graphLookup    (MongoExpressionDSL)
        // case group          (MongoExpressionDSL)
        // case indexStats
        // case limit          (Int)
        // case listSessions   (MongoExpressionDSL)
        // case lookup         (MongoExpressionDSL)
        // case match          (MongoPredicate)
        // case planCacheStats
        // case project        (MongoProjection.Document)
        // case redact         (MongoExpression)
        // case replaceRoot    (MongoExpressionDSL)
        // case sample         (MongoExpressionDSL)
        // case set            (MongoExpressionDSL)
        // case setWindowFields(MongoExpressionDSL)
        // case skip           (Int)
        // case sort           (MongoExpressionDSL)
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
        _ populate:(inout MongoExpressionDSL) throws -> ()) rethrows -> Self
    {
        try .set(populate)
    }
    @available(*, unavailable, renamed: "collectionStats(_:)")
    public static
    func collStats(
        _ populate:(inout MongoExpressionDSL) throws -> ()) rethrows -> Self
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
    func bucket(_ document:__owned MongoPredicate) -> Self
    {
        .init("$bucket", value: document)
    }
    @inlinable public static
    func bucket(_ populate:(inout MongoPredicate) throws -> ()) rethrows -> Self
    {
        .bucket(try .init(with: populate))
    }

    @inlinable public static
    func match(_ document:__owned MongoPredicate) -> Self
    {
        .init("$match", value: document)
    }
    @inlinable public static
    func match(_ populate:(inout MongoPredicate) throws -> ()) rethrows -> Self
    {
        .match(try .init(with: populate))
    }

    @inlinable public static
    func project(_ document:__owned MongoProjection) -> Self
    {
        .init("$project", value: document)
    }
    @inlinable public static
    func project(_ populate:(inout MongoProjection) throws -> ()) rethrows -> Self
    {
        .project(try .init(with: populate))
    }

    @inlinable public static
    func collectionStats(
        _ populate:(inout MongoExpressionDSL) throws -> ()) rethrows -> Self
    {
        try .init("$collStats", with: populate)
    }

    @inlinable public static
    func set(
        _ populate:(inout MongoExpressionDSL) throws -> ()) rethrows -> Self
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
