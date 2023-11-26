import BSONDecoding
import BSONEncoding
import BSON
import MongoSchema

extension Mongo
{
    @frozen public
    struct Pipeline:Sendable
    {
        @usableFromInline internal
        var bson:BSON.List

        @inlinable public
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
        self.init(stages: [])
        try populate(&self.bson.output[as: Mongo.PipelineEncoder.self])
    }
}
extension Mongo.Pipeline:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(stages: try .init(bson: bson))
    }
}
extension Mongo.Pipeline:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.bson.encode(to: &field)
    }
}
extension Mongo.Pipeline:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Never...)
    {
        self.init(stages: [])
    }
}
extension Mongo.Pipeline
{
    @inlinable public static
    var CLUSTER_TIME:Mongo.Variable<UInt64> { .init(name: "CLUSTER_TIME") }

    @inlinable public static
    var NOW:Mongo.Variable<BSON.Millisecond> { .init(name: "NOW") }

    @inlinable public static
    var CURRENT:Mongo.Variable<Any> { .init(name: "CURRENT") }

    @inlinable public static
    var ROOT:Mongo.Variable<Any> { .init(name: "ROOT") }
}
