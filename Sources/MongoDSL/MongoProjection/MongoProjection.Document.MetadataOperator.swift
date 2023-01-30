extension MongoProjection.Document
{
    @frozen public
    enum MetadataOperator:String, Hashable, Sendable
    {
        case meta = "$meta"
    }
}
