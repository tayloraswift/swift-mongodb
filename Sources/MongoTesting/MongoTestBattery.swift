import MongoDB
import NIOPosix

@rethrows public
protocol MongoTestBattery<Configuration>:TestBattery
{
    associatedtype Configuration:MongoTestConfiguration

    static
    var logging:Mongo.LoggingLevel? { get }

    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
}
extension MongoTestBattery
{
    public static
    var logging:Mongo.LoggingLevel? { nil }

    public static
    func run(tests:TestGroup) async throws
    {
        await tests.do
        {
            let executors:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
            defer
            {
                try? executors.syncShutdownGracefully()
            }

            let bootstrap:Mongo.DriverBootstrap = Configuration.bootstrap(on: executors)
            let logger:Mongo.Logger? = Self.logging.map { .init(level: $0) }

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
