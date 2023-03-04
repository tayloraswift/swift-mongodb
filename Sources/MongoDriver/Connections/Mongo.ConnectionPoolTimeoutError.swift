extension Mongo
{
    public
    struct ConnectionPoolTimeoutError:Error, Equatable, Sendable
    {
        public
        let host:Host

        public
        init(host:Host)
        {
            self.host = host
        }
    }
}
extension Mongo.ConnectionPoolTimeoutError:CustomStringConvertible
{
    public
    var description:String
    {
        """
        Timed out while waiting for a connection to '\(self.host)' to become available.
        """
    }
}
