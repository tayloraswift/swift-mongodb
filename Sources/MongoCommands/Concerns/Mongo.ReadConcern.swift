extension Mongo
{
    /// The amount of ratification data needs to have received before it
    /// can be returned by a read command.
    ///
    /// The snapshot read mode is not available as an option, as it can
    /// only be used with transactions and snapshot sessions.
    @frozen public
    enum ReadConcern:String, Hashable, Sendable
    {
        case local
        case available
        case majority
        case linearizable
    }
}
