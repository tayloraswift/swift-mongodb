import Durations
import MongoChannel

extension Mongo
{
    @usableFromInline
    struct SessionMedium:Sendable
    {
        @usableFromInline
        let channel:MongoChannel
        let ttl:Minutes

        init(channel:MongoChannel, ttl:Minutes)
        {
            self.channel = channel
            self.ttl = ttl
        }
    }
}
