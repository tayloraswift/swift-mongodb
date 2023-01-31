import BSONEncoding
import BSONDecoding

extension Mongo.Stage
{
    @frozen public
    struct Group:Sendable
    {
        public
        var fields:BSON.Fields

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.fields = .init(bytes: bytes)
        }
    }
}
extension Mongo.Stage.Group:MongoAccumulatorDSL
{
    public
    typealias Subdocument = Never

    @inlinable public mutating
    func append(key:String, with serialize:(inout BSON.Field) -> ())
    {
        self.fields.append(key: key, with: serialize)
    }
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension Mongo.Stage.Group:BSONEncodable
{
}
extension Mongo.Stage.Group:BSONDecodable
{
}
