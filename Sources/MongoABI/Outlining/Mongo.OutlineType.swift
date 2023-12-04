extension Mongo
{
    @frozen public
    enum OutlineType:String, Hashable, Sendable
    {
        case documents
        case updates
        case deletes
    }
}
