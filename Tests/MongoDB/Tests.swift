import MongoDB
import Testing

extension TestGroup
{
    func withTemporaryDatabase<Success>(named database:Mongo.Database,
        bootstrap:Mongo.DriverBootstrap,
        hosts:Set<Mongo.Host>,
        run body:(Mongo.SessionPool, Mongo.Database) async throws -> Success)
        async -> Success?
    {
        await self.do
        {
            try await bootstrap.withSessionPool(seedlist: hosts)
            {
                //  if we already have a database with this name, drop it.
                try await $0.run(command: Mongo.DropDatabase.init(), against: database)

                let before:[Mongo.Database] = try await $0.run(
                    command: Mongo.ListDatabases.NameOnly.init(),
                    against: .admin)

                let result:Result<Success, any Error>
                do
                {
                    result = .success(try await body($0, database))
                }
                catch let error
                {
                    result = .failure(error)
                }

                try await $0.run(command: Mongo.DropDatabase.init(), against: database)

                let after:[Mongo.Database] = try await $0.run(
                    command: Mongo.ListDatabases.NameOnly.init(),
                    against: .admin)
                
                self.expect(before ..? after)

                return try result.get()
            }
        }
    }
}
