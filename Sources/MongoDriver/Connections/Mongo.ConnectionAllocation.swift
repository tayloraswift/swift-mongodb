import MongoChannel

extension Mongo
{
    struct ConnectionAllocation:Identifiable, Sendable
    {
        let channel:MongoChannel
        let id:UInt

        init(channel:MongoChannel, id:UInt)
        {
            self.channel = channel
            self.id = id
        }
    }
}
