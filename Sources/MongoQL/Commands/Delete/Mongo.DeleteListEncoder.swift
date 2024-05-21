import BSON

extension Mongo
{
    @frozen public
    struct DeleteListEncoder<Effect> where Effect:Mongo.WriteEffect
    {
        @usableFromInline internal
        var output:BSON.Output

        @inlinable internal
        init()
        {
            self.output = .init(preallocated: [])
        }
    }
}
extension Mongo.DeleteListEncoder
{
    @inlinable internal consuming
    func move() -> BSON.Output { self.output }
}
extension Mongo.DeleteListEncoder
{
    @inlinable public mutating
    func callAsFunction<T>(
        with yield:(inout Mongo.DeleteStatementEncoder<Effect>) throws -> T) rethrows -> T
    {
        try yield(&self.output[
            as: Mongo.DeleteStatementEncoder<Effect>.self,
            in: BSON.DocumentFrame.self])
    }
}
