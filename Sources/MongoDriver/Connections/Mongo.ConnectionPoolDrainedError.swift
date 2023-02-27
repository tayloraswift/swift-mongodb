extension Mongo
{
    public
    struct ConnectionPoolDrainedError:Error, Equatable, Sendable
    {
        public
        init()
        {
        }
    }
}
