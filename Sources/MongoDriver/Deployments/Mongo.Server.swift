extension Mongo
{
    struct Server<Metadata>
    {
        let metadata:Metadata
        let pool:ConnectionPool

        init(metadata:Metadata, pool:ConnectionPool)
        {
            self.metadata = metadata
            self.pool = pool
        }
    }
}
extension Mongo.Server
{
    var host:Mongo.Host
    {
        self.pool.host
    }
}
extension Mongo.Server:Sendable where Metadata:Sendable
{
}
extension Mongo.Server
{
    func map<T>(transform:(Metadata) throws -> T) rethrows -> Mongo.Server<T>
    {
        .init(metadata: try transform(self.metadata), pool: self.pool)
    }
}
