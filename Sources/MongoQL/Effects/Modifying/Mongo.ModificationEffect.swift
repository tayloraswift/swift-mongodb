import BSON

extension Mongo
{
    public
    protocol ModificationEffect
    {
        associatedtype ID:BSONDecodable & Sendable
        associatedtype Value:BSONDecodable & Sendable

        associatedtype Phase:ModificationPhase
        associatedtype Upsert:BSONEncodable

        static
        var upsert:Upsert { get }
    }
}
