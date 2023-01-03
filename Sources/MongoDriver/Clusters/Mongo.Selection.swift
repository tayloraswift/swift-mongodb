import MongoChannel

extension Mongo
{
    @frozen public
    struct Selection:Sendable
    {
        public
        let preference:ReadPreference
        public
        let channel:MongoChannel

        init(preference:ReadPreference, channel:MongoChannel)
        {
            self.preference = preference
            self.channel = channel
        }
    }
}
