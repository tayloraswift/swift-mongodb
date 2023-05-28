import MongoDB
import Testing

extension Mongo.DriverBootstrap
{
    func withTemporaryDatabase(named database:Mongo.Database,
        logger:Mongo.Logger? = nil,
        tests:TestGroup,
        run body:(Mongo.SessionPool, Mongo.Database) async throws -> ()) async
    {
        let environment:TestGroup = tests ! "environment"
        await environment.do
        {
            try await self.withSessionPool(logger: logger)
            {
                (pool:Mongo.SessionPool) in

                //  if we already have a database with this name, drop it.
                try await pool.run(command: Mongo.DropDatabase.init(), against: database)

                let before:[Mongo.Database] = try await pool.run(
                    command: Mongo.ListDatabases.NameOnly.init(),
                    against: .admin)

                await tests.do
                {
                    try await body(pool, database)
                }

                try await pool.run(command: Mongo.DropDatabase.init(), against: database)

                let after:[Mongo.Database] = try await pool.run(
                    command: Mongo.ListDatabases.NameOnly.init(),
                    against: .admin)
                
                environment.expect(before ..? after)
            }
        }
    }
}
