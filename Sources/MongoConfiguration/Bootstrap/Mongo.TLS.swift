extension Mongo
{
    @frozen public
    enum TLS:Equatable, Sendable
    {
        case enabled
        case disabled
    }
}
