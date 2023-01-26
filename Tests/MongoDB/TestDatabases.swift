import MongoDB
import Testing

func TestDatabases(_ tests:TestGroup,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<Mongo.Host>) async
{
    let tests:TestGroup = tests / "databases"

    await tests.withTemporaryDatabase(named: "database",
        bootstrap: bootstrap,
        hosts: hosts)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        await (tests / "create-by-collection").do
        {
            try await pool.run(command: Mongo.Create.init(collection: "placeholder"), 
                against: database)
        }

        let tests:TestGroup = tests / "list-databases"

        await tests.do
        {
            let names:[Mongo.Database] = try await pool.run(
                command: Mongo.ListDatabases.NameOnly.init(),
                against: .admin)
            tests.expect(true: names.contains(database))
        }

        await tests.do
        {
            let (size, databases):(Int, [Mongo.DatabaseMetadata]) = try await pool.run(
                command: Mongo.ListDatabases.init(),
                against: .admin)
            tests.expect(true: size > 0)
            tests.expect(true: databases.contains { $0.database == database })
        }
    }
}
