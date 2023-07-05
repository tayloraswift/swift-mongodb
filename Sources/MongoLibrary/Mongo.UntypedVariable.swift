import MongoExpressions

extension Mongo
{
    @frozen public
    struct UntypedVariable:Equatable, Hashable, Sendable
    {
        public
        let name:String

        @inlinable public
        init(name:String)
        {
            self.name = name
        }
    }
}
extension Mongo.UntypedVariable:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.name < rhs.name
    }
}
extension Mongo.UntypedVariable:MongoExpressionVariable
{
}
extension Mongo.UntypedVariable:ExpressibleByStringLiteral
{
}
