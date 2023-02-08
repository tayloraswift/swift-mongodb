public
protocol MongoWriteCommand<Response>:MongoCommand
{
    var writeConcern:Mongo.WriteConcern? { get }
}
