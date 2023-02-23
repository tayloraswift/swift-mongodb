extension Mongo.ConnectionPool
{
    struct Counters
    {
        private
        var current:
        (
            connection:UInt,
            request:UInt
        )

        init()
        {
            self.current = (0, 0)
        }
    }
}
extension Mongo.ConnectionPool.Counters
{
    /// Mints a new connection identifier.
    mutating
    func connection() -> UInt
    {
        self.current.connection += 1
        return self.current.connection
    }
    /// Mints a new request identifier.
    mutating
    func request() -> UInt
    {
        self.current.request += 1
        return self.current.request
    }
}
