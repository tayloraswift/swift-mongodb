import MongoDB

extension Mongo
{
    protocol TestBattery
    {
        var database:Database { get }
        var logging:LogSeverity { get }

        func run(with pool:SessionPool) async throws
    }
}
extension Mongo.TestBattery
{
    var logging:Mongo.LogSeverity { .error }
}
extension Mongo.TestBattery
{
    func run(under configuration:any Mongo.TestConfiguration) async throws
    {
        let bootstrap:Mongo.DriverBootstrap = configuration.bootstrap(on: .singleton)
        try await bootstrap.withSessionPool(logger: .init(level: self.logging))
        {
            try await $0.withTemporaryDatabase(self.database, run: self.run(with:))
        }
    }
}
