extension MongoExpressionDSL.Map
{
    @frozen public
    enum Argument:String, Hashable, Sendable
    {
        case input
        case transform = "in"
    }
}
