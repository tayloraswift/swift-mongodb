extension Mongo.Expression
{
    @frozen public
    enum Zip:String, Hashable, Sendable
    {
        case zip = "$zip"
    }
}
