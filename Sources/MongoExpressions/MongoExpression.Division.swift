extension MongoExpression
{
    @frozen public
    enum Division:String, Hashable, Sendable
    {
        case divide = "$divide"
        case mod    = "$mod"
    }
}
