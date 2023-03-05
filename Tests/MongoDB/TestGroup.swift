import MongoDB
import Testing

extension TestGroup
{
    func withTemporaryDatabase(named database:Mongo.Database,
        bootstrap:Mongo.DriverBootstrap,
        logger:Mongo.Logger? = nil,
        hosts:Set<Mongo.Host>,
        run body:(Mongo.SessionPool, Mongo.Database) async throws -> ()) async
    {
        let environment:TestGroup = self ! "environment"
        await environment.do
        {
            try await bootstrap.withSessionPool(seedlist: hosts, logger: logger)
            {
                (pool:Mongo.SessionPool) in

                //  if we already have a database with this name, drop it.
                try await pool.run(command: Mongo.DropDatabase.init(), against: database)

                let before:[Mongo.Database] = try await pool.run(
                    command: Mongo.ListDatabases.NameOnly.init(),
                    against: .admin)

                await self.do
                {
                    try await body(pool, database)
                }

                try await pool.run(command: Mongo.DropDatabase.init(), against: database)

                let after:[Mongo.Database] = try await pool.run(
                    command: Mongo.ListDatabases.NameOnly.init(),
                    against: .admin)
                
                self.expect(before ..? after)
            }
        }
    }
}
