import BSON

extension Mongo
{
    public
    protocol ModificationPhase:BSONEncodable
    {
        static
        var field:BSON.Key { get }
    }
}
