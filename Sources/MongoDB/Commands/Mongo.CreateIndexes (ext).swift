/// '''
/// Starting in MongoDB 4.4, you can create collections and indexes inside a multi-document
/// transaction if the transaction is not a cross-shard write transaction.
/// '''
extension Mongo.CreateIndexes:Mongo.ImplicitSessionCommand, Mongo.TransactableCommand
{
}
