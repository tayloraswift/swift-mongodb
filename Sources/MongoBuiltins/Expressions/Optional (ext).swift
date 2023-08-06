//  These overloads are unique to ``Mongo.Expression``, because it has
//  operators that take multiple arguments. The other DSLs don't need these.
extension Mongo.Expression?
{
    @inlinable public static
    func expr(with populate:(inout Mongo.Expression) throws -> ()) rethrows -> Self
    {
        return .some(try .expr(with: populate))
    }
}
