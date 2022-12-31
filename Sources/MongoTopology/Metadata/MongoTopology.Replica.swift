extension MongoTopology
{
    @frozen public
    struct Replica:Sendable
    {
        public
        let timings:MongoTopology.Timings
        public
        let tags:[String: String]
    }
}
