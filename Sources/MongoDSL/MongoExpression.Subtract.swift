extension MongoExpression
{
    @frozen public
    enum Subtract:String, Hashable, Sendable
    {
        case subtract = "$subtract"
    }
}
