import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct WriteConcern:Hashable, Sendable
    {
        public
        let journaled:Bool?
        public
        let level:WriteLevel

        @inlinable public
        init(level:WriteLevel, journaled:Bool? = nil)
        {
            self.level = level
            self.journaled = journaled
        }
    }
}
extension Mongo.WriteConcern:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["w"] = self.level
        bson["j"] = self.journaled
        // 'wtimeout' is deprecated
        // bson["wtimeout"] = self.timeout
    }
}
extension Mongo.WriteConcern:BSONDecodable, BSONDictionaryDecodable
{
    @inlinable public
    init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(level: try bson["w"].decode(to: Mongo.WriteLevel.self),
            journaled: try bson["j"]?.decode(to: Bool.self))
    }
}
