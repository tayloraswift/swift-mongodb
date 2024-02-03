import BSON
import Durations

extension Mongo
{
    struct ReplicaQuality:Sendable
    {
        let staleness:Milliseconds
        let latency:Nanoseconds
        let tags:[BSON.Key: String]
    }
}
