import MongoChannel

extension Mongo
{
    public
    struct Connection:Sendable
    {
        let generation:UInt
        public
        let channel:MongoChannel

        init(generation:UInt, channel:MongoChannel)
        {
            self.generation = generation
            self.channel = channel
        }
    }
}
