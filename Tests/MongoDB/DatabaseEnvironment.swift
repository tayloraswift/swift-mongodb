import MongoDB
import MongoTopology
import Testing

struct DatabaseEnvironment
{
    let bootstrap:Mongo.DriverBootstrap,
        database:Mongo.Database,
        hosts:Set<MongoTopology.Host>
    
    init(bootstrap:Mongo.DriverBootstrap, database:Mongo.Database, hosts:Set<MongoTopology.Host>)
    {
        self.bootstrap = bootstrap
        self.database = database
        self.hosts = hosts
    }
}
extension DatabaseEnvironment:AsyncTestEnvironment
{
    struct Context
    {
        let database:Mongo.Database,
            pool:Mongo.SessionPool
        
        init(database:Mongo.Database, pool:Mongo.SessionPool)
        {
            self.database = database
            self.pool = pool
        }
    }

    var name:String
    {
        self.database.name
    }

    func runWithContext<Success>(tests:inout Tests,
        body:(inout Tests, Context) async throws -> Success) async throws -> Success
    {
        try await self.bootstrap.withSessionPool(seedlist: self.hosts)
        {
            //  if we already have a database with this name, drop it.
            try await $0.run(command: Mongo.DropDatabase.init(), against: self.database)

            let before:[Mongo.Database] = try await $0.run(
                command: Mongo.ListDatabases.NameOnly.init(),
                against: .admin)

            let result:Result<Success, any Error>
            do
            {
                result = .success(try await body(&tests, .init(
                    database: self.database,
                    pool: $0)))
            }
            catch let error
            {
                result = .failure(error)
            }

            try await $0.run(command: Mongo.DropDatabase.init(), against: self.database)

            let after:[Mongo.Database] = try await $0.run(
                command: Mongo.ListDatabases.NameOnly.init(),
                against: .admin)
            
            tests.assert(before ..? after, name: "cleanup")

            return try result.get()
        }
    }
}
