import BSON
import MongoChannel

extension Mongo
{
    public
    struct Connection:Sendable
    {
        let generation:UInt
        @usableFromInline
        let channel:MongoChannel

        init(generation:UInt, channel:MongoChannel)
        {
            self.generation = generation
            self.channel = channel
        }
    }
}
