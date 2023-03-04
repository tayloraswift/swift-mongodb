extension MongoIO
{
    @frozen public
    enum Cancellation:Equatable, Sendable
    {
        case timeout
        case cancel
    }
}
