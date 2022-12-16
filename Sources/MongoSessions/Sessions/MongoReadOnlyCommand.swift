/// A type that can encode a MongoDB command that can be run
/// as part of any session.
public
protocol MongoReadOnlyCommand<Response>:MongoSessionCommand
{
}
