import MongoCommands

extension Mongo.FailCommand
{
    @frozen public
    enum Action:Equatable, Sendable
    {
        case error(Int32)
        case writeConcernError(Mongo.WriteConcernError)
    }
}
