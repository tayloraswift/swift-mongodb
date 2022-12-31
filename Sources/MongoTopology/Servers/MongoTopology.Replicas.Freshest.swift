import BSON

extension MongoTopology.Replicas
{
    enum Freshest
    {
        case primary(MongoTopology.Timings)
        case secondary(BSON.Millisecond)
    }
}
