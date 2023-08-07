import MongoQL

extension Mongo.Create<Mongo.Collection>
{
    @frozen public
    enum ValidationLevel:String, Hashable, Sendable
    {
        case validationLevel
    }
}
