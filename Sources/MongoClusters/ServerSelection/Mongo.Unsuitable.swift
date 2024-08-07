import BSON
import UnixTime

extension Mongo
{
    /// A reason why a replica was deemed *unsuitable*.
    @frozen public
    enum Unsuitable:Equatable, Sendable
    {
        case stale(Milliseconds)
        case tags([BSON.Key: String])
    }
}
