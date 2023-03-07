extension Mongo
{
    @frozen public
    enum TopologyHint:Equatable, Sendable
    {
        case replicated(set:String)
    }
}
