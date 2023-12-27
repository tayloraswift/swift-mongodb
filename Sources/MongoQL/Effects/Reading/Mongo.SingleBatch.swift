import BSON

extension Mongo
{
    @frozen public
    enum SingleBatch<Element> where Element:BSONDecodable & Sendable
    {
    }
}
extension Mongo.SingleBatch:Mongo.ReadEffect
{
    public
    typealias Tailing = Never
    public
    typealias Stride = Never
    public
    typealias Batch = [Element]
    public
    typealias BatchElement = Element

    @inlinable public static
    func decode(
        reply bson:BSON.DocumentDecoder<BSON.Key, ArraySlice<UInt8>>) throws -> [Element]
    {
        try bson["cursor"].decode
        {
            if  let cursor:Mongo.CursorIdentifier = .init(rawValue: try $0["id"].decode())
            {
                throw Mongo.SingleOutputError.cursor(cursor)
            }
            else
            {
                return try $0["firstBatch"].decode()
            }
        }
    }
}
