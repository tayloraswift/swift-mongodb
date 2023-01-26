extension Mongo
{
    /// An outcome of committing a ``Transaction``.
    @frozen public
    enum CommitStatus
    {
        /// The transaction was not committed, because there was nothing to commit.
        /// (No user commands were run with the transaction.)
        case cancelled
        /// The transaction was committed.
        case committed
        /// The transaction is in an unknown state.
        case unknown(any Error)
    }
}
