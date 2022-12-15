extension Mongo
{
    @frozen public
    enum TransactionPhase
    {
        case starting
        case aborting
        case committing
    }
}
