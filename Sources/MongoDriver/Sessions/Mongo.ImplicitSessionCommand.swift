import MongoCommands
extension Mongo
{
    /// A type that can encode a MongoDB command that can be run
    /// as part of a session, which can be implicitly generated
    /// if the command is sent to a deployment at large.
    public
    typealias ImplicitSessionCommand = _MongoImplicitSessionCommand
}

/// The name of this protocol is ``Mongo.ImplicitSessionCommand``.
public
protocol _MongoImplicitSessionCommand<Response>:Mongo.Command
{
}
