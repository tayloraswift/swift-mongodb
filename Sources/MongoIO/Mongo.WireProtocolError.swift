extension Mongo
{
    @frozen public
    enum WireProtocolError:Equatable, Error
    {
        case interrupted
        case interruptedAlready
    }
}
extension Mongo.WireProtocolError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .interrupted:          "Connection interrupted"
        case .interruptedAlready:   "Connection interrupted already"
        }
    }
}
