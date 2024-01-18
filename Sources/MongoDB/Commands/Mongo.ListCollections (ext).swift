extension Mongo.ListCollections:Mongo.ImplicitSessionCommand, Mongo.TransactableCommand
{
}
extension Mongo.ListCollections:Mongo.IterableCommand
{
    @inlinable public
    var tailing:Mongo.Tailing? { nil }
}
