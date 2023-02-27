extension MongoIO
{
    @frozen public
    enum CancellationError:Equatable, Error, Sendable
    {
        case timeout
        case cancel
    }
}
