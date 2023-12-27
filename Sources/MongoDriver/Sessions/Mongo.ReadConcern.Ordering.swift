extension Mongo.ReadConcern
{
    enum Ordering:Sendable
    {
        case after(Mongo.Timestamp)
        case at(Mongo.Timestamp)
    }
}
