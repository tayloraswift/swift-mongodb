extension Mongo.ConnectionPool
{
    struct Reservation
    {
        private
        let connector:Mongo.Connector<Mongo.Authenticator>
        let id:UInt

        init(connector:Mongo.Connector<Mongo.Authenticator>, id:UInt)
        {
            self.connector = connector
            self.id = id
        }
    }
}
extension Mongo.ConnectionPool.Reservation
{
    func connect() async throws -> Mongo.ConnectionPool.Allocation
    {
        try await self.connector.connect(id: self.id)
    }
}
