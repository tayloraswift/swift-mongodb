extension Mongo
{
    @frozen public
    enum MaxTime:Hashable, Sendable
    {
        /// The driver will populate the relevant command’s `maxTimeMS`
        /// field automatically.
        case auto
    }
}
