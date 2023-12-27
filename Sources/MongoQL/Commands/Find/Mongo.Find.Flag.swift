extension Mongo.Find
{
    @frozen public
    enum Flag:String, Hashable, Sendable
    {
        case allowDiskUse
        case allowPartialResults
        case noCursorTimeout
        case returnKey
        case showRecordIdentifier = "showRecordId"
    }
}
extension Mongo.Find.Flag
{
    @available(*, unavailable, renamed: "showRecordIdentifier")
    public static
    var showRecordId:Self
    {
        .showRecordIdentifier
    }
}
