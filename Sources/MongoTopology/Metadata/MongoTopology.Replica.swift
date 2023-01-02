import Durations

extension MongoTopology
{
    @frozen public
    struct Replica:Sendable
    {
        public
        let timings:MongoTopology.Timings
        public
        let tags:[String: String]

        @inlinable public
        init(timings:MongoTopology.Timings, tags:[String: String])
        {
            self.timings = timings
            self.tags = tags
        }
    }
}
