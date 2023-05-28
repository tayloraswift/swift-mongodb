import BSONDecoding
import MongoDriver
import NIOCore

extension Mongo
{
    @frozen public
    enum SingleBatch<Element> where Element:BSONDecodable & Sendable
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
    func decode(reply bson:BSON.DocumentDecoder<BSON.Key, ByteBufferView>) throws -> [Element]
    {
        try bson["cursor"].decode
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
