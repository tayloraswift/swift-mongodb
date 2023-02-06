extension Mongo.UnionWithDocument
{
    @frozen public
    enum Collection:String, Hashable, Sendable
    {
        case collection = "coll"
    }
}
extension Mongo.UnionWithDocument.Collection
{
    @available(*, unavailable, renamed: "collection")
    public static
    var coll:Self
    {
        .collection
    }
}
