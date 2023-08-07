extension Mongo.Expression
{
    @frozen public
    enum SortArray:String, Hashable, Sendable
    {
        case sortArray = "$sortArray"
    }
}
