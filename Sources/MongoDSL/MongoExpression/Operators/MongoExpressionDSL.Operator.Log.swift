extension MongoExpressionDSL.Operator
{
    @frozen public
    enum Log:String, Hashable, Sendable
    {
        case log = "$log"
    }
}
