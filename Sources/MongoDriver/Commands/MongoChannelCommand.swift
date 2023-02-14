import BSONEncoding
import MongoWire

protocol MongoChannelCommand:BSONDocumentEncodable, Sendable
{
    /// The type of database this command can be run against.
    associatedtype Database:MongoCommandDatabase = Mongo.Database
}
extension MongoChannelCommand
{
    /// Encodes this command to a BSON document, adding the given database
    /// as a field with the key [`"$db"`]().
    public __consuming
    func encode(database:Database,
        by deadline:ContinuousClock.Instant) -> MongoWire.Message<[UInt8]>.Sections?
    {
        let now:ContinuousClock.Instant = .now

        if now < deadline
        {
            let fields:BSON.Document = .init
            {
                self.encode(to: &$0)
                $0["$db"] = database.name
            }
            return .init(body: .init(fields))
        }
        else
        {
            return nil
        }
    }
}
