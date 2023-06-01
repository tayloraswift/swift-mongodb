import MongoDB

extension Mongo.DriverBootstrap
{
    public
    func run(_ tests:TestGroup, _ batteries:any MongoTestBattery...) async
    {
        await self.run(tests, batteries)
    }
    public
    func run(_ tests:TestGroup, _ batteries:[any MongoTestBattery]) async
    {
        for battery:any MongoTestBattery in batteries
        {
            if  let tests:TestGroup = tests / battery.id
            {
                await tests.do
                {
                    try await self.withTemporaryDatabase(.init(battery.id),
                        logger: battery.logging.map { .init(level: $0) })
                    {
                        try await battery.run(tests, pool: $0, database: $1)
                    }
                }
            }
        }
    }

    /// See ``Mongo.SessionPool.withTemporaryDatabase(_:run:)``.
    public
    func withTemporaryDatabase(_ database:Mongo.Database,
        logger:Mongo.Logger? = nil,
        run body:(Mongo.SessionPool, Mongo.Database) async throws -> ()) async throws
    {
        try await self.withSessionPool(logger: logger)
        {
            (pool:Mongo.SessionPool) in
            try await pool.withTemporaryDatabase(database)
            {
                try await body(pool, database)
            }
        }
    }
}
