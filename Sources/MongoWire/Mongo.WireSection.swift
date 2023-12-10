extension Mongo
{
    @frozen public
    enum WireSection:UInt8, Sendable
    {
        case body       = 0x00
        case sequence   = 0x01
    }
}
