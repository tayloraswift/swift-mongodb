extension Mongo.Pipeline
{
    @frozen public
    enum Bucket:String, Hashable, Sendable
    {
        case bucket = "$bucket"
    }
}
