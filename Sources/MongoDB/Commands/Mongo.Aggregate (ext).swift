extension Mongo.Aggregate:Mongo.ImplicitSessionCommand, Mongo.TransactableCommand
{
}
extension Mongo.Aggregate:Mongo.IterableCommand
    where   Effect.Tailing == Mongo.Tailing,
            Effect.Stride == Int,
            Effect.Batch == Mongo.CursorBatch<Effect.BatchElement>
{
    public
    typealias Element = Effect.BatchElement
}
