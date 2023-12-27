import BSON

extension Mongo
{
    public
    typealias ModificationEffect = _MongoModificationEffect
}
/// The name of this protocol is ``Mongo.ModificationEffect``.
public
protocol _MongoModificationEffect
{
    associatedtype ID:BSONDecodable & Sendable
    associatedtype Value:BSONDecodable & Sendable

    associatedtype Phase:Mongo.ModificationPhase
    associatedtype Upsert:BSONEncodable

    static
    var upsert:Upsert { get }
}
