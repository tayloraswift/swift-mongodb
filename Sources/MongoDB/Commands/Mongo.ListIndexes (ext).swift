extension Mongo.ListIndexes:Mongo.ImplicitSessionCommand
{
}
extension Mongo.ListIndexes:Mongo.IterableCommand
{
    @inlinable public
    var tailing:Mongo.Tailing? { nil }
}
