public
protocol MongoTransactableCommand<Response>:MongoSessionCommand
{
    var writeConcern:Mongo.WriteConcern? { get }
    var readConcern:Mongo.ReadConcern? { get }
}
extension MongoTransactableCommand where Self:MongoReadOnlyCommand
{
    @inlinable public
    var writeConcern:Mongo.WriteConcern?
    {
        nil
    }
}
