import BSONEncoding

public
protocol MongoModificationPhase:BSONEncodable
{
    static
    var field:BSON.Key { get }
}
