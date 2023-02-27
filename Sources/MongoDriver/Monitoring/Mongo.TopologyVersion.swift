import BSONDecoding
import BSONEncoding

extension Mongo
{
    struct TopologyVersion
    {
        let process:BSON.Identifier
        let counter:Int64

        init(process:BSON.Identifier, counter:Int64)
        {
            self.process = process
            self.counter = counter
        }
    }
}
extension Mongo.TopologyVersion:BSONDocumentDecodable, BSONDocumentEncodable
{
    enum CodingKeys:String
    {
        case process = "processId"
        case counter
    }

    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            process: try bson[.process].decode(to: BSON.Identifier.self),
            counter: try bson[.counter].decode(to: Int64.self))
    }

    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.process] = self.process
        bson[.counter] = self.counter
    }
}
