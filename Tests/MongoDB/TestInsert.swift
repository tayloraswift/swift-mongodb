import MongoDB
import Testing

func TestInsert(_ tests:inout Tests,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<Mongo.Host>) async
{
    await tests.withTemporaryDatabase(name: "collection-insert",
        bootstrap: bootstrap,
        hosts: hosts)
    {
        (tests:inout Tests, pool:Mongo.SessionPool, database:Mongo.Database) in

        let collection:Mongo.Collection = "ordinals"

        await tests.test(name: "insert-one")
        {
            let expected:Mongo.InsertResponse = .init(inserted: 1)
            let response:Mongo.InsertResponse = try await pool.run(
                command: Mongo.Insert<Ordinals>.init(collection: collection,
                    elements: .init(identifiers: 0 ..< 1)),
                against: database)
            
            $0.assert(response ==? expected, name: "response")
        }

        await tests.test(name: "insert-multiple")
        {
            let expected:Mongo.InsertResponse = .init(inserted: 15)
            let response:Mongo.InsertResponse = try await pool.run(
                command: Mongo.Insert<Ordinals>.init(collection: collection,
                    elements: .init(identifiers: 1 ..< 16)),
                against: database)
            
            $0.assert(response ==? expected, name: "response")
        }

        await tests.test(name: "insert-duplicate-id")
        {
            let expected:Mongo.InsertResponse = .init(inserted: 0,
                writeErrors:
                [
                    .init(index: 0,
                        message:
                        """
                        E11000 duplicate key error collection: \
                        \(database).\(collection) index: _id_ dup key: { _id: 0 }
                        """,
                        code: 11000),
                ])
            let response:Mongo.InsertResponse = try await pool.run(
                command: Mongo.Insert<Ordinals>.init(collection: collection,
                    elements: .init(identifiers: 0 ..< 1)),
                against: database)
            
            $0.assert(response ==? expected, name: "response")
        }

        await tests.test(name: "insert-ordered")
        {
            let expected:Mongo.InsertResponse = .init(inserted: 8,
                writeErrors:
                [
                    .init(index: 8,
                        message:
                        """
                        E11000 duplicate key error collection: \
                        \(database).\(collection) index: _id_ dup key: { _id: 0 }
                        """,
                        code: 11000),
                ])
            let response:Mongo.InsertResponse = try await pool.run(
                command: Mongo.Insert<Ordinals>.init(collection: collection,
                    elements: .init(identifiers: -8 ..< 32)),
                against: database)
            
            $0.assert(response ==? expected, name: "response")
        }

        await tests.test(name: "insert-unordered")
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
            let response:Mongo.InsertResponse = try await pool.run(
                command: Mongo.Insert<Ordinals>.init(collection: collection,
                    elements: .init(identifiers: -16 ..< 32),
                    ordered: false),
                against: database)
            
            $0.assert(response ==? expected, name: "response")
        }
    }
}
