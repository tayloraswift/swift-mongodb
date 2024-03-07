import BSON

extension Mongo
{
    @frozen public
    struct SortOperatorEncoder:Sendable
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<BSON.Key>

        @inlinable internal
        init(bson:BSON.DocumentEncoder<BSON.Key>)
        {
            self.bson = bson
        }
    }
}
extension Mongo.SortOperatorEncoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output)
    {
        self.init(bson: .init(output))
    }

    @inlinable public consuming
    func move() -> BSON.Output { self.bson.move() }

    @inlinable public static
    var type:BSON.AnyType { .document }
}
extension Mongo.SortOperatorEncoder
{
    /// This is slightly different from its ``Mongo.ProjectionEncoder`` counterpart;
    /// it only accepts `textScore`.
    @frozen public
    enum Meta:String, Hashable, Sendable
    {
        case meta = "$meta"
    }

    @inlinable public
    subscript(key:Meta) -> Mongo.SortMetadata?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
