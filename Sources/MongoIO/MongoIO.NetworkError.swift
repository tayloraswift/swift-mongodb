import MongoWire

extension MongoIO
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
