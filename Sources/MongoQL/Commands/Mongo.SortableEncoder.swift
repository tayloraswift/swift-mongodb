extension Mongo
{
    public
    protocol SortableEncoder<Sort>
    {
        associatedtype Sort:RawRepresentable<String>

        subscript<IndexKey>(key:Sort,
            using _:IndexKey.Type,
            yield:(inout Mongo.SortEncoder<IndexKey>) -> ()) -> Void { mutating get }
    }
}
extension Mongo.SortableEncoder
{
    @available(*, unavailable)
    @inlinable public
    subscript(key:Sort) -> Mongo.SortDocument<Mongo.AnyKeyPath>?
    {
        nil
    }
}
