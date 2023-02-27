extension Mongo
{
    public
    struct ConnectionPoolTimeoutError:Error, Equatable, Sendable
    {
        public
        init()
        {
        }
    }
}
