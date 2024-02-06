import BSON

extension Mongo
{
    @available(*, deprecated, renamed: "DeleteStatementListEncoder")
    public
    typealias DeleteEncoder = DeleteStatementListEncoder

    @frozen public
    struct DeleteStatementListEncoder<Effect> where Effect:Mongo.WriteEffect
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
extension Mongo.DeleteStatementListEncoder
{
    @inlinable internal consuming
    func move() -> BSON.Output { self.output }
}
extension Mongo.DeleteStatementListEncoder
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
