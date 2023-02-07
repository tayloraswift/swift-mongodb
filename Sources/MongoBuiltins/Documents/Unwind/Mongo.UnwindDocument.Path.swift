extension Mongo.UnwindDocument
{
    @frozen public
    enum Path:String, Hashable, Sendable
    {
        case path
    }
}
