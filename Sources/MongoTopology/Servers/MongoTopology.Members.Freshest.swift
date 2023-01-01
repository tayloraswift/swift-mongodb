import BSON

extension MongoTopology.Members
{
    enum Freshest
    {
        case primary(MongoTopology.Timings)
        case secondary(BSON.Millisecond)
    }
}
extension MongoTopology.Members.Freshest
{
    init?(primary:MongoTopology.Server<MongoTopology.Replica>?,
        secondaries:[MongoTopology.Server<MongoTopology.Replica>])
    {
        if let primary:MongoTopology.Server<MongoTopology.Replica>
        {
            self = .primary(primary.connection.metadata.timings)
            return
        }

        let secondary:MongoTopology.Server<MongoTopology.Replica>? =
            secondaries.max
        {
            $0.connection.metadata.timings.write.value <
            $1.connection.metadata.timings.write.value
        }
        if let secondary:MongoTopology.Server<MongoTopology.Replica>
        {
            self = .secondary(secondary.connection.metadata.timings.write)
        }
        else
        {
            return nil
        }
    }
}
