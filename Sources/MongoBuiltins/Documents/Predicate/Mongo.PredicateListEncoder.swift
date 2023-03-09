import BSONEncoding

extension Mongo
{
    @frozen public
    struct PredicateListEncoder
    {
        @usableFromInline internal
        var bson:BSON.ListEncoder

        @inlinable public
        init(output:BSON.Output<[UInt8]>)
        {
            self.bson = .init(output: output)
        }
    }
}
extension Mongo.PredicateListEncoder:BSONEncoder
{
    @inlinable public static
    var type:BSON { .list }

    @inlinable public
    var output:BSON.Output<[UInt8]>
    {
        self.bson.output
    }
}
extension Mongo.PredicateListEncoder
{
    @inlinable public mutating
    func append(_ predicate:Mongo.PredicateDocument)
    {
        self.bson.append(predicate)
    }
    @inlinable public mutating
    func append(with encode:(inout Mongo.PredicateDocument) -> ())
    {
        self.append(.init(with: encode))
    }
}
