extension Mongo
{
    enum TransactionPhase
    {
        case started
        case aborted
        case committed
    }
}
