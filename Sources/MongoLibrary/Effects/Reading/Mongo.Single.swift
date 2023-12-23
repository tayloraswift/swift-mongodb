import BSON
import MongoDriver
import NIOCore

extension Mongo
{
    @frozen public
    enum Single<Element> where Element:BSONDecodable & Sendable
    {
    }
}
extension Mongo.Single:Mongo.ReadEffect
{
    public
    typealias Tailing = Never
    public
    typealias Stride = Never
    public
    typealias Batch = Element?
    public
    typealias BatchElement = Element

    @inlinable public static
    func decode(reply bson:BSON.DocumentDecoder<BSON.Key, ByteBufferView>) throws -> Element?
    {
        try bson["cursor"].decode
        {
            if  let cursor:Mongo.CursorIdentifier = .init(
                    rawValue: try $0["id"].decode(to: Int64.self))
            {
                throw Mongo.SingleOutputError.cursor(cursor)
            }

            let elements:[Element] = try $0["firstBatch"].decode()

            if  elements.count > 1
            {
                throw Mongo.SingleOutputError.count(elements.count)
            }
            else
            {
                return elements.first
            }
        }
    }
}
