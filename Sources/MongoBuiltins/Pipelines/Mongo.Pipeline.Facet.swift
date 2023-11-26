extension Mongo.Pipeline
{
    @frozen public
    enum Facet:String, Hashable, Sendable
    {
        case facet = "$facet"
    }
}
