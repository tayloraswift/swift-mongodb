import MongoDB
import Testing

@Suite
struct Insert
{
    private
    let collection:Mongo.Collection = "ordinals"
    private
    let database:Mongo.Database = "Insert"

    @Test(arguments: [.single, .replicated] as [any Mongo.TestConfiguration])
    func insert(_ configuration:any Mongo.TestConfiguration) async throws
    {
        let bootstrap:Mongo.DriverBootstrap = configuration.bootstrap(on: .singleton)
        try await bootstrap.withSessionPool(logger: .init(level: .error))
        {
            (pool:Mongo.SessionPool) in

            try await pool.withTemporaryDatabase(self.database, run: self.run(with:))
        }
    }

    private
    func run(with pool:Mongo.SessionPool) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)

        do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 1)
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(self.collection,
                    encoding: Ordinals.init(identifiers: 0 ..< 1)),
                against: self.database)

            #expect(response == expected)
        }
        do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 15)
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(self.collection,
                    encoding: Ordinals.init(identifiers: 1 ..< 16)),
                against: self.database)

            #expect(response == expected)
        }
        do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 0,
                writeErrors:
                [
                    .init(index: 0,
                        message:
                        """
                        E11000 duplicate key error collection: \
                        \(self.database).\(self.collection) index: _id_ dup key: { _id: 0 }
                        """,
                        code: 11000),
                ])
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(self.collection,
                    encoding: Ordinals.init(identifiers: 0 ..< 1)),
                against: self.database)

            #expect(response == expected)
        }
        do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 8,
                writeErrors:
                [
                    .init(index: 8,
                        message:
                        """
                        E11000 duplicate key error collection: \
                        \(self.database).\(self.collection) index: _id_ dup key: { _id: 0 }
                        """,
                        code: 11000),
                ])
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(self.collection,
                    encoding: Ordinals.init(identifiers: -8 ..< 32)),
                against: self.database)

            #expect(response == expected)
        }
        do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 24,
                writeErrors: (8 ..< 32).map
                {
                    .init(index: $0,
                        message:
                        """
                        E11000 duplicate key error collection: \
                        \(database).\(collection) index: _id_ dup key: { _id: \($0 - 16) }
                        """,
                        code: 11000)
                })

            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(self.collection,
                    encoding: Ordinals.init(identifiers: -16 ..< 32))
                {
                    $0[.ordered] = false
                },
                against: self.database)

            #expect(response == expected)
        }
    }
}
