import BSON

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
    @inlinable public static
    var type:Mongo.CommandType { .endSessions }
}
extension Mongo.EndSessions:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<Mongo.CommandType>)
    {
        bson[Self.type] = self.sessions
    }
}
