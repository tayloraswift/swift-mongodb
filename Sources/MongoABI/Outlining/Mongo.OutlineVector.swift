import BSON

extension Mongo
{
    @frozen public
    struct OutlineVector:Sendable
    {
        public
        let bson:BSON.Output
        public
        let type:OutlineType

        @inlinable public
        init(bson:BSON.Output, type:OutlineType)
        {
            self.bson = bson
            self.type = type
        }
    }
}
