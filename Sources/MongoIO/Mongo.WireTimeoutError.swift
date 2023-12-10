extension Mongo
{
    /// An operation timed out while waiting for a wire response from the server.
    ///
    /// Wire timeouts are expensive, because the driver needs to tear down and re-establish
    /// connections after enforcing them.
    @frozen public
    struct WireTimeoutError:Error, Equatable
    {
        @inlinable public
        init()
        {
        }
    }
}
