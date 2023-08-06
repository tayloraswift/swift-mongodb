extension Mongo.Expression
{
    @frozen public
    enum Subtract:String, Hashable, Sendable
    {
        case subtract = "$subtract"
    }
}
