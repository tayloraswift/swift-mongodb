import BSONDecoding
import BSONEncoding
import BSONUnions

@frozen public
struct MongoPipeline:Sendable
{
    @usableFromInline
    var stages:[Stage]

    @inlinable public
    init(stages:[Stage])
    {
        self.stages = stages
    }
}
extension MongoPipeline:BSONDecodable
{
    @inlinable public
    init(bson:AnyBSON<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(stages: try .init(bson: bson))
    }
}
extension MongoPipeline:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.stages.encode(to: &field)
    }
}
extension MongoPipeline:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Stage...)
    {
        self.init(stages: arrayLiteral)
    }
}
extension MongoPipeline:RandomAccessCollection
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
    subscript(index:Int) -> Stage
    {
        self.stages[index]
    }
}
extension MongoPipeline
{
    @inlinable public mutating
    func append(_ stage:Stage)
    {
        self.stages.append(stage)
    }
    @inlinable public mutating
    func append(_ populate:(inout Stage) throws -> ()) rethrows
    {
        self.append(try .init(with: populate))
    }
}
