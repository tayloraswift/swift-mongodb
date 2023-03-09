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
    @inlinable public static
    var type:Mongo.CommandType { .ping }

    public
    var fields:BSON.Document
    {
        Self.type(1 as Int32)
    }
}
