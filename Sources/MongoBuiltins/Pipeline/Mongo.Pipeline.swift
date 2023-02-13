import BSONDecoding
import BSONEncoding
import BSONUnions

extension Mongo
{
    @frozen public 
    struct Pipeline:Sendable
    {
        @usableFromInline
        var stages:[PipelineStage]

        @inlinable public
        init(stages:[PipelineStage])
        {
            self.stages = stages
        }
    }
}
extension Mongo.Pipeline
{
    @inlinable public
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(stages: [])
        try populate(&self)
    }
}
extension Mongo.Pipeline:BSONDecodable
{
    @inlinable public
    init(bson:AnyBSON<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(stages: try .init(bson: bson))
    }
}
extension Mongo.Pipeline:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.stages.encode(to: &field)
    }
}
extension Mongo.Pipeline:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Mongo.PipelineStage...)
    {
        self.init(stages: arrayLiteral)
    }
}
extension Mongo.Pipeline:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        self.stages.startIndex
    }
    @inlinable public
    var endIndex:Int
    {
        self.stages.endIndex
    }
    @inlinable public
    subscript(index:Int) -> Mongo.PipelineStage
    {
        self.stages[index]
    }
}
extension Mongo.Pipeline
{
    @inlinable public mutating
    func append(_ stage:Mongo.PipelineStage)
    {
        self.stages.append(stage)
    }
    @inlinable public mutating
    func append(_ populate:(inout Mongo.PipelineStage) throws -> ()) rethrows
    {
        self.append(try .init(with: populate))
    }
}
