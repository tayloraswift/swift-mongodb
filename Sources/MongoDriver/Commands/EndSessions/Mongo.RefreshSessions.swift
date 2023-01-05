import BSONEncoding

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
extension Mongo.RefreshSessions:MongoSessionCommand, MongoCommand
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["refreshSessions"] = self.sessions
    }
}
