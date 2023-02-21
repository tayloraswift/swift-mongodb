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
    func decode(reply:BSON.DocumentDecoder<BSON.UniversalKey, ByteBufferView>) throws -> Response
}
extension MongoBatchingMode where Response:BSONDocumentDecodable<BSON.UniversalKey>
{
    @inlinable public static
    func decode(reply:BSON.DocumentDecoder<BSON.UniversalKey, ByteBufferView>) throws -> Response
    {
        try .init(bson: reply)
    }
}
