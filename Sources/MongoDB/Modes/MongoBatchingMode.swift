import BSONDecoding
import NIOCore

public
protocol MongoBatchingMode
{
    associatedtype Response:Sendable

    associatedtype Element:Sendable// & BSONDocumentDecodable
    associatedtype Tailing:Sendable
    associatedtype Stride:Sendable

    static
    func decode(reply:BSON.Dictionary<ByteBufferView>) throws -> Response
}
extension MongoBatchingMode where Response:BSONDictionaryDecodable
{
    @inlinable public static
    func decode(reply:BSON.Dictionary<ByteBufferView>) throws -> Response
    {
        try .init(bson: reply)
    }
}
