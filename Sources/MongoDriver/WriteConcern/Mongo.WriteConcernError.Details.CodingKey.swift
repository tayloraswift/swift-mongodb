extension Mongo.WriteConcernError.Details
{
    @frozen public
    enum CodingKey:String
    {
        case writeConcern
    }
}
