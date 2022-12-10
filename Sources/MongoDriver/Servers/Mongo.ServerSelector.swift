extension Mongo
{
    @frozen public
    enum ServerSelector:Sendable
    {
        case master
        case any
    }
}
