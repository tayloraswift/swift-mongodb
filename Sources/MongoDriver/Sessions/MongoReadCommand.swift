public
protocol MongoReadCommand<Response>:MongoSessionCommand
{
    var readLevel:Mongo.ReadLevel? { get }
}
