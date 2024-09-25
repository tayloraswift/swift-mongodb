import MongoDB
import NIOPosix

@rethrows public
protocol MongoTestBattery<Configuration>:TestBattery
{
    associatedtype Configuration:MongoTestConfiguration

    static
    var logging:Mongo.LogSeverity { get }

    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
}
extension MongoTestBattery
{
    public static
    var logging:Mongo.LogSeverity { .error }

    public static
    func run(tests:TestGroup) async throws
    {
        await tests.do
        {
            let bootstrap:Mongo.DriverBootstrap = Configuration.bootstrap(on: .singleton)
            let logger:Mongo.Logger = .init(level: Self.logging)

            try await bootstrap.withSessionPool(logger: logger)
            {
                (pool:Mongo.SessionPool) in

                let database:Mongo.Database = .init(Self.name)
                try await pool.withTemporaryDatabase(database)
                {
                    try await Self.run(tests: tests, pool: pool, database: database)
                }
            }
        }
    }
}
