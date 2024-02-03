import Durations

/// The name of this protocol is ``Mongo.ReplicaTimingBaseline``.
public
protocol _MongoReplicaTimingBaseline
{
    static
    func - (self:Self, candidate:Mongo.ReplicaTimings) -> Milliseconds
}

extension Mongo
{
    public
    typealias ReplicaTimingBaseline = _MongoReplicaTimingBaseline
}
