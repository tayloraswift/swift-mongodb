import BSONDecoding
import BSONEncoding

extension Mongo.WriteConcern
{
    public
    struct Options:Hashable, Sendable
    {
        public
        let acknowledgement:Acknowledgement
        public
        let journaled:Bool?

        private
        init(unchecked acknowledgement:Acknowledgement, journaled:Bool?)
        {
            self.acknowledgement = acknowledgement
            self.journaled = journaled
        }
    }
}
extension Mongo.WriteConcern.Options
{
    public
    init(acknowledgement:Mongo.WriteConcern.Acknowledgement, journaled:Bool? = nil)
    {
        if case .votes(0) = acknowledgement
        {
            self.init(unchecked: acknowledgement, journaled: nil)
        }
        else
        {
            self.init(unchecked: acknowledgement, journaled: journaled)
        }
    }

    public
    init(_ write:Mongo.WriteConcern)
    {
        self.init(unchecked: write.acknowledgement, journaled: write.journaled)
    }

    public static
    var unacknowledged:Self
    {
        .init(unchecked: .votes(0), journaled: nil)
    }
}
extension Mongo.WriteConcern.Options:BSONDecodable, BSONDictionaryDecodable
{
    @inlinable public
    init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            acknowledgement: try bson["w"].decode(to: Mongo.WriteConcern.Acknowledgement.self),
            journaled: try bson["j"]?.decode(to: Bool.self))
    }
}
extension Mongo.WriteConcern.Options:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Document)
    {
        bson["w"] = self.acknowledgement
        bson["j"] = self.journaled
        // 'wtimeout' is deprecated
        // bson["wtimeout"] = self.timeout
    }
}
