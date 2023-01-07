public
protocol MongoReadCommand<Response>:MongoCommand
{
    var readLevel:Mongo.ReadLevel? { get }
}
