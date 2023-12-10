import BSON

extension Mongo
{
    @frozen public
    struct OutlineVector:Sendable
    {
        public
        let bson:BSON.Output<[UInt8]>
        public
        let type:OutlineType

        @inlinable public
        init(bson:BSON.Output<[UInt8]>, type:OutlineType)
        {
            self.bson = bson
            self.type = type
        }
    }
}
