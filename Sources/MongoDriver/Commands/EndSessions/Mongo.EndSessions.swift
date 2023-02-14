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
extension Mongo.EndSessions:MongoChannelCommand
{
    /// The string [`"endSessions"`]().
    @inlinable public static
    var name:String
    {
        "endSessions"
    }

    /// `EndSessions` must be run against to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    public
    func encode(to bson:inout BSON.Document)
    {
        bson[Self.name] = self.sessions
    }
}
