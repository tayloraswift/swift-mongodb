extension Mongo.Pipeline
{
    @frozen public
    enum GeoNear:String, Hashable, Sendable
    {
        case geoNear = "$geoNear"
    }
}
