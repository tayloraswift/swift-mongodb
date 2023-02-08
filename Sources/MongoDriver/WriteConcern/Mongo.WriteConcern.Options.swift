import BSONEncoding

extension Mongo.WriteConcern
{
    struct Options:Hashable, Sendable
    {
        let acknowledgement:Acknowledgement
        let journaled:Bool?

        private
        init(acknowledgement:Acknowledgement, journaled:Bool? = nil)
        {
            self.acknowledgement = acknowledgement
            self.journaled = journaled
        }
    }
}
extension Mongo.WriteConcern.Options
{
    init(_ write:Mongo.WriteConcern)
    {
        self.init(acknowledgement: write.acknowledgement, journaled: write.journaled)
    }

    static
    var unacknowledged:Self
    {
        .init(acknowledgement: .votes(0), journaled: nil)
    }
}

extension Mongo.WriteConcern.Options:BSONEncodable, BSONDocumentEncodable
{
    func encode(to bson:inout BSON.Fields)
    {
        bson["w"] = self.acknowledgement
        bson["j"] = self.journaled
        // 'wtimeout' is deprecated
        // bson["wtimeout"] = self.timeout
    }
}
