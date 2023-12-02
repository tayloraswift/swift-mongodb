import BSON

public
protocol MongoModificationPhase:BSONEncodable
{
    static
    var field:BSON.Key { get }
}
