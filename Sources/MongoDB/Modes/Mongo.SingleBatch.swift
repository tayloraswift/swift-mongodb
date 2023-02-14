import BSONDecoding
import NIOCore

extension Mongo
{
    public
    enum SingleBatch<Element> where Element:BSONDocumentDecodable & Sendable
    {
    }
}
extension Mongo.SingleBatch:MongoBatchingMode
{
    public
    typealias Response = [Element]
    public
    typealias Tailing = Never
    public
    typealias Stride = Void

    @inlinable public static
    func decode(reply bson:BSON.Dictionary<ByteBufferView>) throws -> [Element]
    {
        try bson["cursor"].decode(as: BSON.Dictionary<ByteBufferView>.self)
        {
            if  let cursor:Mongo.CursorIdentifier = .init(
                    rawValue: try $0["id"].decode(to: Int64.self))
            {
                throw Mongo.CursorIdentifierError.init(invalid: cursor)
            }
            else
            {
                return try $0["firstBatch"].decode(to: [Element].self)
            }
        }
    }
}
