extension MongoPredicate.Operator
{
    @frozen public
    enum Regex:String, Hashable, Sendable
    {
        case regex = "$regex"
    }
}
