public
protocol MongoGetMoreCommand:MongoCommand
{
    var timeout:Mongo.OperationTimeout? { get }
}
