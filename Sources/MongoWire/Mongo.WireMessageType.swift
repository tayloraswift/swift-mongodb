extension Mongo
{
    @frozen public
    enum WireMessageType:Int32, Sendable
    {
        // case compressed = 2012
        case message    = 2013
    }
}
