extension Mongo.Pipeline
{
    @frozen public
    enum Redact:String, Hashable, Sendable
    {
        case redact = "$redact"
    }
}
