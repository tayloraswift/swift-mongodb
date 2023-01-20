import MongoDB
import Testing

extension Tests
{
    mutating
    func withTemporaryDatabase<Success>(name database:Mongo.Database,
        bootstrap:Mongo.DriverBootstrap,
        hosts:Set<Mongo.Host>,
        run body:(inout Tests, Mongo.SessionPool, Mongo.Database) async throws -> Success)
        async -> Success?
    {
        await self.test(name: database.name)
        {
            (self:inout Self) in

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
                    result = .success(try await body(&self, $0, database))
                }
                catch let error
                {
                    result = .failure(error)
                }

                try await $0.run(command: Mongo.DropDatabase.init(), against: database)

                let after:[Mongo.Database] = try await $0.run(
                    command: Mongo.ListDatabases.NameOnly.init(),
                    against: .admin)
                
                self.assert(before ..? after, name: "cleanup")

                return try result.get()
            }
        }
    }
    // mutating
    // func withSession<Success>(name:String,
    //     pool:Mongo.SessionPool,
    //     run body:(inout Tests, Mongo.Session) async throws -> Success) async -> Success?
    // {
    //     await self.test(name: name)
    //     {
    //         (self:inout Self) in
    //         try await pool.withSession
    //         {
    //             try await body(&self, $0)
    //         }
    //     }
    // }
}
