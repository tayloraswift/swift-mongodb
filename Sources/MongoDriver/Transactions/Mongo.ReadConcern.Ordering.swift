extension Mongo.ReadConcern
{
    enum Ordering:Sendable
    {
        case after(Mongo.Instant)
        case at(Mongo.Instant)
    }
}
