extension Mongo
{
    @frozen public
    enum MaxTime:Equatable, Hashable, Sendable
    {
        /// The driver will compute and populate the relevant command’s `maxTimeMS` field
        /// automatically, based on user-specified timeout arguments.
        case computed
        /// The driver will omit the relevant command’s `maxTimeMS` field. This is used by
        /// ``GetMore`` commands, to avoid repeating the `maxTimeMS` field from the original
        /// cursor-returning command.
        case omitted
    }
}
