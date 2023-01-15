extension Mongo
{
    public
    struct Replica:Sendable
    {
        public
        let timings:Timings
        public
        let tags:[String: String]

        public
        init(timings:Timings, tags:[String: String])
        {
            self.timings = timings
            self.tags = tags
        }
    }
}
