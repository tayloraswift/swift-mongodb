import MongoCommands

extension Mongo
{
    public
    protocol TransactableCommand<Response>:Command
    {
    }
}
