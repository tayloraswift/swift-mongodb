import BSON

extension Mongo
{
    @frozen public
    struct DeleteEncoder<Effect> where Effect:Mongo.WriteEffect
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
extension Mongo.DeleteEncoder
{
    @inlinable internal consuming
    func move() -> BSON.Output { self.output }
}
extension Mongo.DeleteEncoder
{
    @inlinable public mutating
    func callAsFunction<T>(
        with yield:(inout Mongo.DeleteStatement<Effect>) throws -> T) rethrows -> T
    {
        try yield(&self.output[
            as: Mongo.DeleteStatement<Effect>.self,
            in: BSON.DocumentFrame.self])
    }
}
