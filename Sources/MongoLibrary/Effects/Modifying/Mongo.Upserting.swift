import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    enum Upserting<Value, ID>:MongoModificationEffect
        where Value:BSONDecodable, ID:BSONDecodable
    {
        public
        typealias Phase = Mongo.UpdatePhase

        @inlinable public static
        var upsert:Bool { true }
    }
}
