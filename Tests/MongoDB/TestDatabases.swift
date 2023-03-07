import MongoDB
import Testing

func TestDatabases(_ tests:TestGroup, bootstrap:Mongo.DriverBootstrap) async
{
    guard let tests:TestGroup = tests / "databases"
    else
    {
        return
    }

    await bootstrap.withTemporaryDatabase(named: "database", tests: tests)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        await (tests ! "create-by-collection").do
        {
            try await pool.run(
                command: Mongo.Create<Mongo.Collection>.init(collection: "placeholder"), 
                against: database)
        }

        let tests:TestGroup = tests ! "list-databases"

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
