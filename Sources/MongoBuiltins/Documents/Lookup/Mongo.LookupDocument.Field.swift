extension Mongo.LookupDocument
{
    @frozen public
    enum Field:String, Hashable, Sendable
    {
        case `as`
        case localField
        case foreignField
    }
}
