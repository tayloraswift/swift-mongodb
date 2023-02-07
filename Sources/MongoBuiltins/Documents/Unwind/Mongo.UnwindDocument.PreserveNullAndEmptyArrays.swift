extension Mongo.UnwindDocument
{
    @frozen public
    enum PreserveNullAndEmptyArrays:String, Hashable, Sendable
    {
        case preserveNullAndEmptyArrays
    }
}
