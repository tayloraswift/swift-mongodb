extension Mongo
{
    @frozen public
    enum TransactionPhase:Sendable, Equatable
    {
        case autocommitting
        case starting(ReadConcern.Level?)
        case started
    }
}
