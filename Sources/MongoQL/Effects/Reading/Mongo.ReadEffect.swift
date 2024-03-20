import BSON

extension Mongo
{
    public
    protocol ReadEffect
    {
        associatedtype Tailing:Sendable = Mongo.Tailing
        associatedtype Stride:Sendable & BSONEncodable
        associatedtype Batch:Sendable
        associatedtype BatchElement:Sendable & BSONDecodable

        static
        func decode(reply:BSON.DocumentDecoder<BSON.Key>) throws -> Batch
    }
}
extension Mongo.ReadEffect where Batch:BSONDocumentDecodable<BSON.Key>
{
    @inlinable public static
    func decode(reply:BSON.DocumentDecoder<BSON.Key>) throws -> Batch
    {
        try .init(bson: reply)
    }
}
