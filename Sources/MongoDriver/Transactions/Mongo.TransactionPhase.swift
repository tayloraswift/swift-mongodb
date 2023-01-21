extension Mongo
{
    @frozen public
    enum TransactionPhase:Sendable
    {
        case starting(ReadConcern.Level?)
        case started
    }
}
