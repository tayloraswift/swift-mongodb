import BSONEncoding

extension Mongo
{
    struct EndSessions:Error, Sendable
    {
        let sessions:[SessionIdentifier]

        init(_ sessions:[SessionIdentifier])
        {
            self.sessions = sessions
        }
    }
}
extension Mongo.EndSessions:MongoCommand
{
    struct Response
    {
    }

    static
    func decode(reply:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws -> Response
    {
        print(reply)
        return .init()
    }
    
    func encode(to bson:inout BSON.Fields)
    {
        bson["endSessions"] = self.sessions
    }
}
