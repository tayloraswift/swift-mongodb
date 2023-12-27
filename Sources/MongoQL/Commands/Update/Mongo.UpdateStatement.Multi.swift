extension Mongo.UpdateStatement
{
    @frozen public
    enum Multi:String, Hashable, Sendable
    {
        case multi
    }
}
