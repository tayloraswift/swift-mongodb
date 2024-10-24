import MongoDB
import Testing

@Suite
struct Databases:Mongo.TestBattery
{
    let database:Mongo.Database = "Databases"

    @Test(arguments: [.single, .replicated] as [any Mongo.TestConfiguration])
    func databases(_ configuration:any Mongo.TestConfiguration) async throws
    {
        try await self.run(under: configuration)
    }

    func run(with pool:Mongo.SessionPool) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)

        try await session.run(
            command: Mongo.Create<Mongo.Collection>.init("Placeholder"),
            against: self.database)

        let names:[Mongo.Database] = try await session.run(
            command: Mongo.ListDatabases.NameOnly.init(),
            against: .admin)

        #expect(names.contains(self.database))

        let (size, databases):(Int, [Mongo.DatabaseMetadata]) = try await session.run(
            command: Mongo.ListDatabases.init(),
            against: .admin)

        #expect(size > 0)
        #expect(databases.contains { $0.database == self.database })
    }
}
