import MongoConnection

extension MongoTopology
{
    @frozen public
    struct Server<Metadata>
    {
        public
        var connection:MongoConnection<Metadata>
        public
        let host:Host

        @inlinable public
        init(connection:MongoConnection<Metadata>, host:Host)
        {
            self.connection = connection
            self.host = host
        }
    }
}
extension MongoTopology.Server:Sendable where Metadata:Sendable
{
}
extension MongoTopology.Server
{
    @inlinable public
    func map<T>(transform:(Metadata) throws -> T) rethrows -> MongoTopology.Server<T>
    {
        .init(connection: try connection.map(transform), host: self.host)
    }
}
