import BSON

extension Mongo
{
    public
    typealias ReadEffect = _MongoReadEffect
}
/// The name of this protocol is ``Mongo.ReadEffect``.
public
protocol _MongoReadEffect
{
    associatedtype Tailing:Sendable = Mongo.Tailing
    associatedtype Stride:Sendable & BSONEncodable
    associatedtype Batch:Sendable
    associatedtype BatchElement:Sendable & BSONDecodable

    static
    func decode(reply:BSON.DocumentDecoder<BSON.Key, ArraySlice<UInt8>>) throws -> Batch
}
extension Mongo.ReadEffect where Batch:BSONDocumentDecodable<BSON.Key>
{
    @inlinable public static
    func decode(reply:BSON.DocumentDecoder<BSON.Key, ArraySlice<UInt8>>) throws -> Batch
    {
        try .init(bson: reply)
    }
}
