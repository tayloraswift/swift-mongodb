extension Mongo.ReadConcern
{
    enum Ordering
    {
        case after(Mongo.Instant)
        case at(Mongo.Instant)
    }
}
