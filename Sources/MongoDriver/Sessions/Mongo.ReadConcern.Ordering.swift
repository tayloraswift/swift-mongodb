import BSON

extension Mongo.ReadConcern
{
    enum Ordering:Sendable
    {
        case after(BSON.Timestamp)
        case at(BSON.Timestamp)
    }
}
