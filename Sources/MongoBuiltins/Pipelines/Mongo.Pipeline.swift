import BSON
import MongoABI
import UnixTime

extension Mongo
{
    @frozen public
    struct Pipeline:Sendable
    {
        @usableFromInline internal
        var bson:BSON.List

        @inlinable
        init(stages bson:BSON.List)
        {
            self.bson = bson
        }
    }
}
extension Mongo.Pipeline
{
    @inlinable public
    init(with populate:(inout Mongo.PipelineEncoder) throws -> ()) rethrows
    {
        self.init(stages: BSON.List.init())
        try populate(&self.bson.output[as: Mongo.PipelineEncoder.self])
    }
}
extension Mongo.Pipeline:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        self.init(stages: try .init(bson: bson))
    }
}
extension Mongo.Pipeline:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        self.bson.encode(to: &field)
    }
}
extension Mongo.Pipeline:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Never...)
    {
        self.init(stages: BSON.List.init())
    }
}
extension Mongo.Pipeline
{
    @inlinable public static
    var CLUSTER_TIME:Mongo.Variable<UInt64> { .init(name: "CLUSTER_TIME") }

    @inlinable public static
    var NOW:Mongo.Variable<UnixMillisecond> { .init(name: "NOW") }

    @inlinable public static
    var CURRENT:Mongo.Variable<Any> { .init(name: "CURRENT") }

    @inlinable public static
    var ROOT:Mongo.Variable<Any> { .init(name: "ROOT") }
}
