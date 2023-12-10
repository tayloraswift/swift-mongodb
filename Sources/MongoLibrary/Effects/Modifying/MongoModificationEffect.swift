import BSON

public
protocol MongoModificationEffect
{
    associatedtype ID:BSONDecodable & Sendable
    associatedtype Value:BSONDecodable & Sendable

    associatedtype Phase:MongoModificationPhase
    associatedtype Upsert:BSONEncodable

    static
    var upsert:Upsert { get }
}
