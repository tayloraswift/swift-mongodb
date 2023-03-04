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
