import BSONDecoding
import NIOCore

public
protocol MongoBatchingMode
{
    associatedtype CommandResponse:Sendable = Self

    associatedtype Element:Sendable & BSONDocumentDecodable
    associatedtype Tailing:Sendable
    associatedtype Stride:Sendable

    static
    func decode(reply:BSON.Dictionary<ByteBufferView>) throws -> CommandResponse
}
extension MongoBatchingMode where CommandResponse:BSONDictionaryDecodable
{
    @inlinable public static
    func decode(reply:BSON.Dictionary<ByteBufferView>) throws -> CommandResponse
    {
        try .init(bson: reply)
    }
}
