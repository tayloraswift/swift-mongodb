import BSON

public
protocol MongoFailpoint:BSONEncodable, Sendable
{
    static
    var name:String { get }
}
