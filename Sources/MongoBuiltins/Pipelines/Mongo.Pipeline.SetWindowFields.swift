extension Mongo.Pipeline
{
    @frozen public
    enum SetWindowFields:String, Hashable, Sendable
    {
        case setWindowFields = "$setWindowFields"
    }
}
