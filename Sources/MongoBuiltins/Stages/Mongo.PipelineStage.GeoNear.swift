extension Mongo.PipelineStage
{
    @frozen public
    enum GeoNear:String, Hashable, Sendable
    {
        case geoNear = "$geoNear"
    }
}
