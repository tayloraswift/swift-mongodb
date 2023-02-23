import MongoWire

extension MongoChannel
{
    @frozen public
    enum NetworkError:Error
    {
        case disconnected
        case interrupted
        case perished(any Error)
        case other(any Error)
    }
}
