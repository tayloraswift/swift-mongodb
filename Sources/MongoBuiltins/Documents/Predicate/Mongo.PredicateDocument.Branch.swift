extension Mongo.PredicateDocument
{
    @frozen public
    enum Branch:String, Hashable, Sendable
    {
        case and    = "$and"
        case nor    = "$nor"
        case or     = "$or"
    }
}
