extension Mongo
{
    @frozen public
    enum TransactionPhase:Sendable
    {
        case starting(ReadConcern?)
        case started
    }
}
