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
@available(*, unavailable, message: "Ping cannot be run during a transaction.")
extension Mongo.Ping:MongoTransactableCommand
{
}
extension Mongo.Ping:MongoImplicitSessionCommand, MongoCommand
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
