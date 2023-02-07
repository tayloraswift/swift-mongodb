extension Mongo.PipelineStage
{
    @frozen public
    enum Facet:String, Hashable, Sendable
    {
        case facet = "$facet"
    }
}
