extension Mongo
{
    public
    protocol PredicateEncodable
    {
        func encode(to predicate:inout PredicateEncoder)
    }
}
