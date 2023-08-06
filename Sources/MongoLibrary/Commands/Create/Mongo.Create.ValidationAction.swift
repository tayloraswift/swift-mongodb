import MongoQL

extension Mongo.Create<Mongo.Collection>
{
    @frozen public
    enum ValidationAction:String, Hashable, Sendable
    {
        case validationAction
    }
}
