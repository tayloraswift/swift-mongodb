import BSON

extension Mongo
{
    public
    typealias ModificationPhase = _MongoModificationPhase
}
/// The name of this protocol is ``Mongo.ModificationPhase``.
public
protocol _MongoModificationPhase:BSONEncodable
{
    static
    var field:BSON.Key { get }
}
