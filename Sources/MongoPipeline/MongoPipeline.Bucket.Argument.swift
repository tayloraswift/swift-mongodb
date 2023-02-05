extension MongoPipeline.Bucket
{
    @frozen public
    enum Argument:String, Hashable, Sendable
    {
        case boundaries
        case `default`
    }
}
