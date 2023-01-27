import Durations

extension Mongo.FailCommand
{
    @frozen public
    enum Behavior:Equatable, Sendable
    {
        case blockConnection(for:Milliseconds = 0, then:ErrorMode)
        case closeConnection
    }
}
