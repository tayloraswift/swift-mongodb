extension Mongo
{
    @frozen public
    enum TransactionLabels
    {
        case starting(Int64)
        case started(Int64)
    }
}
