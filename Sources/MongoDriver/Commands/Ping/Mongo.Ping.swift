import BSONEncoding

extension Mongo
{
    /// The MongoDB `ping` command.
    public
    struct Ping:Equatable, Sendable
    {
        public
        init()
        {
        }
    }
}
extension Mongo.Ping:MongoCommand
{
    /// The string [`"ping"`]().
    @inlinable public static
    var name:String
    {
        "ping"
    }

    public
    func encode(to bson:inout BSON.Fields)
    {
        bson[Self.name] = 1 as Int32
    }
}

