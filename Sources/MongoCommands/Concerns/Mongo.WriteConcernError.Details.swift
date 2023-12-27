import BSON

extension Mongo.WriteConcernError
{
    public
    struct Details:Hashable, Sendable
    {
        public
        let acknowledgement:Mongo.WriteConcern.Acknowledgement
        public
        let provenance:Mongo.WriteConcernProvenance
        public
        let journaled:Bool?

        public
        init(acknowledgement:Mongo.WriteConcern.Acknowledgement,
            provenance:Mongo.WriteConcernProvenance,
            journaled:Bool? = nil)
        {
            self.acknowledgement = acknowledgement
            self.provenance = provenance
            self.journaled = journaled
        }
    }
}
extension Mongo.WriteConcernError.Details
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case j
        case provenance
        case w
    }
}
extension Mongo.WriteConcernError.Details:BSONDecodable, BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            acknowledgement: try bson[.w].decode(to: Mongo.WriteConcern.Acknowledgement.self),
            provenance: try bson[.provenance].decode(to: Mongo.WriteConcernProvenance.self),
            journaled: try bson[.j]?.decode(to: Bool.self))
    }
}
extension Mongo.WriteConcernError.Details:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.w] = self.acknowledgement
        bson[.provenance] = self.provenance
        bson[.j] = self.journaled
    }
}
