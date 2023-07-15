import BSONDecoding
import BSONEncoding
extension Delete
{
    struct Cake:Equatable, Hashable, BSONDocumentDecodable, BSONDocumentEncodable
    {
        let location:String
        let flavor:String
        let status:String
        let points:Int

        init(location:String,
            flavor:String,
            status:String,
            points:Int)
        {
            self.location = location
            self.flavor = flavor
            self.status = status
            self.points = points
        }

        enum CodingKey:String
        {
            case location
            case flavor
            case status
            case points
        }

        init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>)
            throws
        {
            self.init(location: try bson[.location].decode(),
                flavor: try bson[.flavor].decode(),
                status: try bson[.status].decode(),
                points: try bson[.points].decode())
        }

        func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
        {
            bson[.location] = self.location
            bson[.flavor] = self.flavor
            bson[.status] = self.status
            bson[.points] = self.points
        }
    }
}
