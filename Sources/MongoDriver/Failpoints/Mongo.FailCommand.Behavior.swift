import UnixTime

extension Mongo.FailCommand
{
    @frozen public
    enum Behavior:Equatable, Sendable
    {
        case blockConnection(for:Milliseconds = .zero, then:Action)
        case closeConnection
    }
}
