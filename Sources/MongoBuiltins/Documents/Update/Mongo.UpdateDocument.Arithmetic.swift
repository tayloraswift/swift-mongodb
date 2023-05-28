extension Mongo.UpdateDocument
{
    @frozen public
    enum Arithmetic:String, Hashable, Sendable
    {
        case inc = "$inc"
        case mul = "$mul"
    }
}
