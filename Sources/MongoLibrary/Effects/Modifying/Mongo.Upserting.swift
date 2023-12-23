import BSON

extension Mongo
{
    @frozen public
    enum Upserting<Value, ID>:Mongo.ModificationEffect
        where   Value:BSONDecodable,
                Value:Sendable,
                ID:BSONDecodable,
                ID:Sendable
    {
        public
        typealias Phase = Mongo.UpdatePhase

        @inlinable public static
        var upsert:Bool { true }
    }
}
