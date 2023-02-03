extension MongoPredicate
{
    @frozen public
    enum Expr:String, Hashable, Sendable
    {
        case expr = "$expr"
    }
}
