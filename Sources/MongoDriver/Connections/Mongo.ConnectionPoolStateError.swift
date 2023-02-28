extension Mongo
{
    /// A connection pool had not been started before making a request to it.
    public
    struct ConnectionPoolInactiveError:Error, Equatable, Sendable
    {
        public
        init()
        {
        }
    }
}
