extension MongoPipeline.Bucket
{
    @frozen public
    enum Output:String, Hashable, Sendable
    {
        case output
    }
}
