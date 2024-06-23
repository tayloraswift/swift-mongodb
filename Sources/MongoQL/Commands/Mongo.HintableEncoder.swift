extension Mongo
{
    public
    protocol HintableEncoder<Hint>
    {
        associatedtype Hint:RawRepresentable<String>

        subscript(key:Hint) -> String? { get set }

        subscript<IndexKey>(key:Hint,
            using _:IndexKey.Type,
            yield:(inout Mongo.SortEncoder<IndexKey>) -> ()) -> Void { mutating get }
    }
}
extension Mongo.HintableEncoder
{
    @available(*, unavailable)
    @inlinable public
    subscript(key:Hint) -> Mongo.SortDocument<Mongo.AnyKeyPath>?
    {
        nil
    }
}
