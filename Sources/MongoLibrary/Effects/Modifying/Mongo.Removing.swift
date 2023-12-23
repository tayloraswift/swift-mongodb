import BSON

extension Mongo
{
    @frozen public
    enum Removing<Document>:Mongo.ModificationEffect where Document:BSONDecodable & Sendable
    {
        public
        typealias Phase = Mongo.RemovePhase
        public
        typealias Value = Document?
        public
        typealias ID = Never

        @inlinable public static
        var upsert:Never? { nil }
    }
}
