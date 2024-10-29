extension Mongo
{
    public
    protocol PredicateConfigurable<PredicateArgument>
    {
        associatedtype PredicateArgument:RawRepresentable<String>

        subscript(key:PredicateArgument, yield:(inout Mongo.PredicateEncoder) -> ()) -> Void
        {
            mutating get
        }
    }
}
extension Mongo.PredicateConfigurable
{
    @inlinable public
    subscript<PredicateDocument>(key:PredicateArgument) -> PredicateDocument?
        where PredicateDocument:Mongo.PredicateEncodable
    {
        get { nil }
        set (value) { value.map { self[key, $0.encode(to:)] } }
    }
}
