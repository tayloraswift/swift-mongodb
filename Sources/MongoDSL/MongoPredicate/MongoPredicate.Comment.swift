extension MongoPredicate
{
    @frozen public
    enum Comment:String, Hashable, Sendable
    {
        case comment = "$comment"
    }
}
