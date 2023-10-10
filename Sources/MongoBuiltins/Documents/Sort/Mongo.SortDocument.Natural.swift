extension Mongo.SortDocument
{
    @frozen public
    enum Natural:String, Hashable, Sendable
    {
        case natural = "$natural"
    }
}
