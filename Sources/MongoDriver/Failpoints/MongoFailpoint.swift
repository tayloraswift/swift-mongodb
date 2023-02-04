import BSONEncoding

public
protocol MongoFailpoint:BSONEncodable, Sendable
{
    static
    var name:String { get }
}
