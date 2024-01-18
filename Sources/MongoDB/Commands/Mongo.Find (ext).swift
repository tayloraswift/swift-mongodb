extension Mongo.Find:Mongo.ImplicitSessionCommand, Mongo.TransactableCommand
{
}
extension Mongo.Find:Mongo.IterableCommand
    where   Effect.Tailing == Mongo.Tailing,
            Effect.Stride == Int,
            Effect.Batch == Mongo.CursorBatch<Effect.BatchElement>
{
    public
    typealias Element = Effect.BatchElement
}
