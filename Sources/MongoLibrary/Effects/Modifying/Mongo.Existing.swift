import BSON

extension Mongo
{
    @frozen public
    enum Existing<Document>:Mongo.ModificationEffect where Document:BSONDecodable & Sendable
    {
        public
        typealias Phase = Mongo.UpdatePhase
        public
        typealias Value = Document?
        public
        typealias ID = Never

        @inlinable public static
        var upsert:Bool { false }
    }
}
