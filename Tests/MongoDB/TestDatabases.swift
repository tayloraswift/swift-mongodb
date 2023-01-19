import MongoDB
import Testing

func TestDatabases(_ tests:inout Tests,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<Mongo.Host>) async
{
    await tests.withTemporaryDatabase(name: "databases",
        bootstrap: bootstrap,
        hosts: hosts)
    {
        (tests:inout Tests, pool:Mongo.SessionPool, database:Mongo.Database) in

        await tests.test(name: "create-database-by-collection")
        {
            _ in 
            try await pool.run(command: Mongo.Create.init(collection: "placeholder"), 
                against: database)
        }

        await tests.test(name: "list-database-names")
        {
            let names:[Mongo.Database] = try await pool.run(
                command: Mongo.ListDatabases.NameOnly.init(),
                against: .admin)
            $0.assert(names.contains(database),
                name: "contains")
        }

        await tests.test(name: "list-databases")
        {
            let (size, databases):(Int, [Mongo.DatabaseMetadata]) = try await pool.run(
                command: Mongo.ListDatabases.init(),
                against: .admin)
            $0.assert(size > 0,
                name: "nonzero-size")
            $0.assert(databases.contains { $0.database == database },
                name: "contains")
        }
    }
}
