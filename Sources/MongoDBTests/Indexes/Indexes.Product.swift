import BSON

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

        enum CodingKey:String, Sendable
        {
            case item
            case manufacturer
            case supplier
            case model
        }

        init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
        {
            self.init(item: try bson[.item].decode(),
                manufacturer: try bson[.manufacturer].decode(),
                supplier: try bson[.supplier].decode(),
                model: try bson[.model].decode())
        }

        func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
        {
            bson[.item] = self.item
            bson[.manufacturer] = self.manufacturer
            bson[.supplier] = self.supplier
            bson[.model] = self.model
        }
    }
}
