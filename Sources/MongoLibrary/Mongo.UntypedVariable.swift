import MongoSchema

extension Mongo
{
    @available(*, deprecated, renamed: "Mongo.Variable")
    public
    typealias UntypedVariable = Mongo.Variable<Any>
}
