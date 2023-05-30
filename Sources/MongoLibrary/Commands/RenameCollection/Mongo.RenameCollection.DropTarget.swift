extension Mongo.RenameCollection
{
    @frozen public
    enum DropTarget:String, Hashable, Sendable
    {
        case dropTarget
    }
}
