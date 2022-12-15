extension Mongo
{
    @frozen public
    enum SessionMediumSelector:Sendable
    {
        case master
        case any
    }
}
