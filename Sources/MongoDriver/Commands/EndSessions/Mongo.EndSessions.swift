import BSONEncoding

extension Mongo
{
    /// The MongoDB `endSessions` command.
    ///
    /// This command is internal because the driver manages session
    /// lifecycles automatically.
    struct EndSessions:Sendable
    {
        let sessions:[SessionIdentifier]

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
extension Mongo.EndSessions:MongoCommand
{
    /// `EndSessions` must be sent to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    /// The string [`"endSessions"`]().
    @inlinable public static
    var name:String
    {
        "endSessions"
    }

    public
    var fields:BSON.Fields
    {
        .init
        {
            $0[Self.name] = self.sessions
        }
    }
}
