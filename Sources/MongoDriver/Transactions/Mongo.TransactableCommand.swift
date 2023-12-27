import MongoCommands

extension Mongo
{
    public
    typealias TransactableCommand = _MongoTransactableCommand
}

@available(*, deprecated, renamed: "Mongo.TransactableCommand")
public
typealias MongoTransactableCommand = Mongo.TransactableCommand

public
protocol _MongoTransactableCommand<Response>:Mongo.Command
{
}
