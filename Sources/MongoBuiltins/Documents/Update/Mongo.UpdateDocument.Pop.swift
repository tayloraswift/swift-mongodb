extension Mongo.UpdateDocument
{
    @frozen public
    enum Pop:String, Hashable, Sendable
    {
        case pop = "$pop"
    }
}
