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
extension Mongo.EndSessions
{
    /// The string [`"endSessions"`]().
    @inlinable public static
    var name:BSON.Key
    {
        "endSessions"
    }
}
extension Mongo.EndSessions:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        bson[Self.name] = self.sessions
    }
}
