extension Mongo
{
    /// An outcome of aborting a ``Transaction``.
    @frozen public
    enum AbortionStatus
    {
        /// The transaction was not aborted, because there was nothing to abort.
        /// (No user commands were run with the transaction.)
        case cancelled
        /// The transaction abortion succeeded.
        case aborted
        /// The transaction abortion failed.
        ///
        /// In most cases, this status can be ignored, because running the next
        /// command with the relevant session will purge the server-side transaction
        /// state.
        case failed(any Error)
    }
}
