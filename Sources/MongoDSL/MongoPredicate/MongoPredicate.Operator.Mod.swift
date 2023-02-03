extension MongoPredicate.Operator
{
    @frozen public
    enum Mod:String, Hashable, Sendable
    {
        case mod = "$mod"
    }
}
