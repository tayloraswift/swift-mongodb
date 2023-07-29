extension Mongo
{
    @frozen public
    enum TransactionResult<Success>
    {
        /// The transaction was not started, because server selection failed.
        case unavailable(DeploymentStateError<ReadPreferenceError>)
        /// The transaction was not started, because the deployment does
        /// not support transactions.
        case unsupported(TransactionsUnsupportedError)
        /// The transaction was not started because another transaction
        /// is already in progress.
        case rejection(TransactionInProgressError)
        /// The transaction was started, but an abortion was attempted
        /// because user code threw an error.
        case abortion(any Error, AbortionStatus)
        /// The transaction was started, and a commit was attempted because
        /// user code returned success.
        case commit(Success, CommitStatus)
    }
}
extension Mongo.TransactionResult
{
    /// Attempts to unwrap the return value of this result, throwing an error
    /// if the result indicates the transaction failed. If the transaction
    /// failed because user code threw an error, and the transaction abortion
    /// also failed, this function throws the original user error. If the user
    /// code returned successfully, but the transaction commit failed, this
    /// function throws the commit error.
    @inlinable public
    func callAsFunction() throws -> Success
    {
        switch self
        {
        case    .commit(let success, .cancelled),
                .commit(let success, .committed):
            return success

        case    .commit(_, .unknown(let error)),
                .unavailable(let error as any Error),
                .unsupported(let error as any Error),
                .rejection(let error as any Error),
                .abortion(let error, _):
            throw error
        }
    }
}
