/// A type that can encode a MongoDB authentication command. Authentication commands
/// always return an instance of ``Mongo/SASLResponse``.
protocol MongoAuthenticationCommand:MongoCommand<Mongo.SASLResponse>
{
    associatedtype Response = Mongo.SASLResponse
}
