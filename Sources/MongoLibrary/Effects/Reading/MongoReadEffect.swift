import BSON
import MongoDriver
import NIOCore

public
protocol MongoReadEffect
{
    associatedtype Tailing:Sendable = Mongo.Tailing
    associatedtype Stride:Sendable
    associatedtype Batch:Sendable
    associatedtype BatchElement:Sendable & BSONDecodable

    static
    func decode(reply:BSON.DocumentDecoder<BSON.Key, ByteBufferView>) throws -> Batch
}
extension MongoReadEffect where Batch:BSONDocumentDecodable<BSON.Key>
{
    @inlinable public static
    func decode(reply:BSON.DocumentDecoder<BSON.Key, ByteBufferView>) throws -> Batch
    {
        try .init(bson: reply)
    }
}
