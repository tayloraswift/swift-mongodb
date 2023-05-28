import MongoWire

extension Mongo
{
    @frozen public
    struct OutlinePayload:Sendable
    {
        public
        let vector:OutlineVector
        public
        let type:OutlineType

        @inlinable public
        init(vector:OutlineVector, type:OutlineType)
        {
            self.vector = vector
            self.type = type
        }
    }
}
extension Mongo.OutlinePayload
{
    var outline:MongoWire.Message<[UInt8]>.Outline
    {
        .init(id: self.type.rawValue, slice: self.vector.slice)
    }
}
