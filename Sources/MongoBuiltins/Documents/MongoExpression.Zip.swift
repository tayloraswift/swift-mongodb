import MongoDSL

extension MongoExpression
{
    @frozen public
    enum Zip:String, Hashable, Sendable
    {
        case zip = "$zip"
    }
}
