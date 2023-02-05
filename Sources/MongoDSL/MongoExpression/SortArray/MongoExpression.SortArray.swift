extension MongoExpression
{
    @frozen public
    enum SortArray:String, Hashable, Sendable
    {
        case sortArray = "$sortArray"
    }
}
