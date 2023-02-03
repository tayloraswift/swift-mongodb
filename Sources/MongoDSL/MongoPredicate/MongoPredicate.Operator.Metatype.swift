extension MongoPredicate.Operator
{
    @frozen public
    enum Metatype:String, Hashable, Sendable
    {
        case type = "$type"
    }
}
