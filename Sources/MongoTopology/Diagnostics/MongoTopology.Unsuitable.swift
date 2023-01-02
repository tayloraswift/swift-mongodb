import Durations

extension MongoTopology
{
    /// A reason why a replica was deemed *unsuitable*.
    @frozen public
    enum Unsuitable:Equatable, Sendable
    {
        case stale(Milliseconds)
        case tags([String: String])
    }
}
