import BSONDecoding
import BSONEncoding

extension Indexes
{
    struct Product:Equatable, Hashable, BSONDocumentDecodable, BSONDocumentEncodable
    {
        let item:Int
        let manufacturer:String
        let supplier:String
        let model:String

        init(item:Int,
            manufacturer:String,
            supplier:String,
            model:String)
        {
            self.item = item
            self.manufacturer = manufacturer
            self.supplier = supplier
            self.model = model
        }

        enum CodingKeys:String
        {
            case item
            case manufacturer
            case supplier
            case model
        }

        init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
        {
            self.init(item: try bson[.item].decode(),
                manufacturer: try bson[.manufacturer].decode(),
                supplier: try bson[.supplier].decode(),
                model: try bson[.model].decode())
        }

        func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
        {
            bson[.item] = self.item
            bson[.manufacturer] = self.manufacturer
            bson[.supplier] = self.supplier
            bson[.model] = self.model
        }
    }
}
