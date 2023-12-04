import BSON

extension Mongo
{
    @frozen public
    struct UpdateEncoder<Effect> where Effect:MongoWriteEffect
    {
        @usableFromInline internal
        var output:BSON.Output<[UInt8]>

        @inlinable internal
        init()
        {
            self.output = .init(preallocated: [])
        }
    }
}
extension Mongo.UpdateEncoder
{
    @inlinable internal consuming
    func move() -> BSON.Output<[UInt8]> { self.output }
}
extension Mongo.UpdateEncoder
{
    @inlinable public mutating
    func callAsFunction<T>(
        with yield:(inout Mongo.UpdateStatement<Effect>) throws -> T) rethrows -> T
    {
        try yield(&self.output[
            as: Mongo.UpdateStatement<Effect>.self,
            in: BSON.DocumentFrame.self])
    }
}
