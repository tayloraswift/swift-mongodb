import BSONDecoding
import BSONEncoding

public
protocol MongoModificationEffect
{
    associatedtype ID:BSONDecodable
    associatedtype Value:BSONDecodable

    associatedtype Phase:MongoModificationPhase
    associatedtype Upsert:BSONEncodable

    static
    var upsert:Upsert { get }
}
