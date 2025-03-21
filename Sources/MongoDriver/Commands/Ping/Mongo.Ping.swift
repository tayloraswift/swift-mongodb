import BSON
import MongoCommands

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
extension Mongo.Ping:Mongo.TransactableCommand
{
}
extension Mongo.Ping:Mongo.ImplicitSessionCommand, Mongo.Command
{
    @inlinable public static
    var type:Mongo.CommandType { .ping }

    public
    var fields:BSON.Document
    {
        Self.type(nil)
    }
}
