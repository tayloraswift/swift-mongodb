extension Mongo
{
    /// The amount of ratification data needs to have received before it
    /// can be returned by a read command.
    ///
    /// The snapshot read level is not available as an option, as it can
    /// only be used with transactions and snapshot sessions.
    @frozen public
    enum ReadLevel:Hashable, Sendable
    {
        case local
        case available
        case majority
        case linearizable
    }
}
