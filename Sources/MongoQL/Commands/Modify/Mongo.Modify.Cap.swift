extension Mongo.Modify<Mongo.Collection>
{
    @frozen public
    enum Cap:String, Sendable
    {
        case cappedSize
        case cappedMax
    }
}
