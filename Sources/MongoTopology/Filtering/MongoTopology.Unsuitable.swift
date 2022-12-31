import Durations

extension MongoTopology
{
    @frozen public
    enum Unsuitable:Equatable, Sendable
    {
        case stale(Milliseconds)
        case tags([String: String])
    }
}
