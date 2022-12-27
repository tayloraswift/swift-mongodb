/// A type that can encode a MongoDB command that can be run
/// as part of a session, which can be implicitly generated
/// if the command is sent to a deployment at large.
public
protocol MongoImplicitSessionCommand<Response>:MongoSessionCommand
{
}
