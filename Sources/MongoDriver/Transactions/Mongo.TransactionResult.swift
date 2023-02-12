extension Mongo
{
    @frozen public
    enum TransactionResult<Success>
    {
        /// The transaction was not started, most likely because server
        /// selection failed.
        case unavailable(Mongo.DeploymentStateError<Mongo.ReadPreferenceError>)
        /// The transaction was started, but an abortion was attempted
        /// because user code threw an error.
        case abortion(any Error, AbortionStatus)
        /// The transaction was started, and a commit was attempted because
        /// user code returned success.
        case commit(Success, CommitStatus)
    }
}
