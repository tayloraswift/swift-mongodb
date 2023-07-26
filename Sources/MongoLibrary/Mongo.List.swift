import BSONEncoding
import MongoExpressions
import MongoSchema

extension Mongo
{
    @frozen public
    struct List<Element, Encodable> where Encodable:BSONEncodable
    {
        public
        let expression:Encodable

        @inlinable public
        init(in expression:Encodable)
        {
            self.expression = expression
        }
    }
}
extension Mongo.List
{
    @inlinable public
    func map(
        _ output:(Mongo.Variable<Element>) -> some BSONEncodable) -> Mongo.MapDocument
    {
        let variable:Mongo.Variable<Element> = "self"
        return .let(variable)
        {
            $0[.input] = .expr { $0[.coalesce] = (self.expression, [] as [Never]) }
            $0[.in] = output(variable)
        }
    }
    @inlinable public
    func flatMap(
        _ output:(Mongo.Variable<Element>) -> some BSONEncodable) -> Mongo.ReduceDocument
    {
        .init
        {
            $0[.input] = .expr
            {
                $0[.map] = self.map(output)
            }
            $0[.initialValue] = [] as [Never]
            $0[.in] = .expr
            {
                $0[.concatArrays] = ("$$value", "$$this")
            }
        }
    }
    @inlinable public
    func filter(
        where predicate:(Mongo.Variable<Element>) -> some BSONEncodable) -> Mongo.FilterDocument
    {
        let variable:Mongo.Variable<Element> = "self"
        return .let(variable)
        {
            $0[.input] = .expr { $0[.coalesce] = (self.expression, [] as [Never]) }
            $0[.cond] = predicate(variable)
        }
    }
}
