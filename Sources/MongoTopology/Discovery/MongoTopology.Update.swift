import MongoChannel

extension MongoTopology
{
    public
    struct Update:Sendable
    {
        public
        let channel:MongoChannel
        public
        let variant:Variant?

        @inlinable public
        init(variant:Variant?, channel:MongoChannel)
        {
            self.channel = channel
            self.variant = variant
        }
    }
}
