extension Mongo.Create<Mongo.Collection>
{
    @frozen public
    enum Validator:String, Hashable, Sendable
    {
        case validator
    }
}
