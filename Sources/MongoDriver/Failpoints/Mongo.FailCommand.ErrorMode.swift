extension Mongo.FailCommand
{
    @frozen public
    enum ErrorMode:Equatable, Sendable
    {
        case code(Int32)
        case writeConcern(Mongo.WriteConcernError)
    }
}
