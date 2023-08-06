import BSONEncoding
import MongoSchema

extension Mongo
{
    public
    struct RefreshSessions:Sendable
    {
        let sessions:[SessionIdentifier]

        public
        init(_ session:SessionIdentifier)
        {
            self.sessions = [session]
        }

        public
        init?(_ sessions:[SessionIdentifier])
        {
            if  sessions.isEmpty
            {
                return nil
            }
            else
            {
                self.sessions = sessions
            }
        }
    }
}
@available(*, unavailable, message: "RefreshSessions cannot be run during a transaction.")
extension Mongo.RefreshSessions:MongoTransactableCommand
{
}
extension Mongo.RefreshSessions:MongoCommand, MongoImplicitSessionCommand
{
    /// The string [`"refreshSessions"`]().
    @inlinable public static
    var type:Mongo.CommandType { .refreshSessions }

    /// `RefreshSessions` must be run against to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    public
    var fields:BSON.Document
    {
        Self.type(self.sessions)
    }
}
