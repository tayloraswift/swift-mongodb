extension Mongo
{
    @frozen public
    struct WireProtocolError:Equatable, Error
    {
        @inlinable public
        init()
        {
        }
    }
}
