import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct TopologyVersion
    {
        public
        let process:BSON.Identifier
        public
        let counter:Int64

        @inlinable public
        init(process:BSON.Identifier, counter:Int64)
        {
            self.process = process
            self.counter = counter
        }
    }
}
extension Mongo.TopologyVersion:BSONDocumentDecodable, BSONDocumentEncodable
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case process = "processId"
        case counter
    }

    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            process: try bson[.process].decode(to: BSON.Identifier.self),
            counter: try bson[.counter].decode(to: Int64.self))
    }

    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.process] = self.process
        bson[.counter] = self.counter
    }
}
