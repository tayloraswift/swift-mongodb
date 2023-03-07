import BSONDecoding
import NIOCore

public
protocol MongoBatchingMode
{
    associatedtype Response:Sendable

    associatedtype Element:Sendable// & BSONDecodable
    associatedtype Tailing:Sendable
    associatedtype Stride:Sendable

    static
    func decode(reply:BSON.DocumentDecoder<BSON.Key, ByteBufferView>) throws -> Response
}
extension MongoBatchingMode where Response:BSONDocumentDecodable<BSON.Key>
{
    @inlinable public static
    func decode(reply:BSON.DocumentDecoder<BSON.Key, ByteBufferView>) throws -> Response
    {
        try .init(bson: reply)
    }
}
