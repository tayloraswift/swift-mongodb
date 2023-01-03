import Durations
import MongoChannel

extension Mongo
{
    @frozen public
    struct ReadMedium:Sendable
    {
        public
        var clusterTime:Mongo.ClusterTime
        public
        let channel:MongoChannel

        init(clusterTime:Mongo.ClusterTime, channel:MongoChannel)
        {
            self.clusterTime = clusterTime
            self.channel = channel
        }
    }
}
