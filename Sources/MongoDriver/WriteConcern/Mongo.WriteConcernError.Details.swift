import BSONDecoding
import BSONEncoding

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
extension Mongo.WriteConcernError.Details:BSONDecodable, BSONDictionaryDecodable
{
    @inlinable public
    init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            acknowledgement: try bson["w"].decode(to: Mongo.WriteConcern.Acknowledgement.self),
            provenance: try bson["provenance"].decode(to: Mongo.WriteConcernProvenance.self),
            journaled: try bson["j"]?.decode(to: Bool.self))
    }
}
extension Mongo.WriteConcernError.Details:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Document)
    {
        bson["w"] = self.acknowledgement
        bson["provenance"] = self.provenance
        bson["j"] = self.journaled
    }
}
