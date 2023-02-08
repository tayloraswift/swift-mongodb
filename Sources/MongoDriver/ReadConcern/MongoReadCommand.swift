public
protocol MongoReadCommand<Response>:MongoCommand
{
    var readConcern:Mongo.ReadConcern? { get }
}
