extension Mongo
{
    @frozen public
    enum TransactionLabels
    {
        case autocommitting(Int64)
        case starting(Int64)
        case started(Int64)
    }
}
