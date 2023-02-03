extension MongoSortOrdering.Operator
{
    //  This is slightly different from its ``MongoProjection`` counterpart;
    //  it only accepts `textScore`.
    @frozen public
    enum Meta:String, Hashable, Sendable
    {
        case meta = "$meta"
    }
}
