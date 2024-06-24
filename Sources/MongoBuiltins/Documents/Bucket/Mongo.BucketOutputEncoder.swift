import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct BucketOutputEncoder:Sendable
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<BSON.Key>

        @inlinable
        init(bson:BSON.DocumentEncoder<BSON.Key>)
        {
            self.bson = bson
        }
    }
}
extension Mongo.BucketOutputEncoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output)
    {
        self.init(bson: .init(output))
    }

    @inlinable public consuming
    func move() -> BSON.Output { self.bson.move() }

    @inlinable public static
    var frame:BSON.DocumentFrame { .document }
}

extension Mongo.BucketOutputEncoder
{
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> Mongo.Accumulator?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: path.stem]) }
    }
}
