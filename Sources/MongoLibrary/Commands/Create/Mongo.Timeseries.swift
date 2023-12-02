import BSON

extension Mongo
{
    @frozen public
    struct Timeseries:Sendable
    {
        public
        let timeField:String
        public
        let metaField:String?
        public
        let granularity:Granularity

        @inlinable public
        init(timeField:String, metaField:String? = nil, granularity:Granularity = .seconds)
        {
            self.timeField = timeField
            self.metaField = metaField
            self.granularity = granularity
        }
    }
}
extension Mongo.Timeseries
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case timeField
        case metaField
        case granularity
    }
}
extension Mongo.Timeseries:BSONDecodable, BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            timeField: try bson[.timeField].decode(to: String.self),
            metaField: try bson[.metaField]?.decode(to: String.self),
            granularity: try bson[.granularity].decode(to: Granularity.self))
    }
}
extension Mongo.Timeseries:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.timeField] = self.timeField
        bson[.metaField] = self.metaField
        bson[.granularity] = self.granularity
    }
}
