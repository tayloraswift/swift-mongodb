import BSONEncoding

extension Mongo
{
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
    func encode(to bson:inout BSON.Fields)
    {
        bson["endSessions"] = self.sessions
    }
}
