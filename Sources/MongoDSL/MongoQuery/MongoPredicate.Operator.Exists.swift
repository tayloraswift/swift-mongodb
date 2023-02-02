extension MongoPredicate.Operator
{
    @frozen public
    enum Exists:String, Hashable, Sendable
    {
        case exists = "$exists"
    }
}
