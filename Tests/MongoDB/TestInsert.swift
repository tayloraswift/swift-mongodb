import MongoDB
import Testing

func TestInsert(_ tests:TestGroup, bootstrap:Mongo.DriverBootstrap) async
{
    guard let tests:TestGroup = tests / "insert"
    else
    {
        return
    }
    
    await bootstrap.withTemporaryDatabase(named: "insert-tests", tests: tests)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        let collection:Mongo.Collection = "ordinals"
        let session:Mongo.Session = try await .init(from: pool)
        do
        {
            let tests:TestGroup = tests ! "one"
            await tests.do
            {
                let expected:Mongo.InsertResponse = .init(inserted: 1)
                let response:Mongo.InsertResponse = try await session.run(
                    command: Mongo.Insert.init(collection: collection,
                        elements: Ordinals.init(identifiers: 0 ..< 1)),
                    against: database)
                
                tests.expect(response ==? expected)
            }
        }
        do
        {
            let tests:TestGroup = tests ! "multiple"
            await tests.do
            {
                let expected:Mongo.InsertResponse = .init(inserted: 15)
                let response:Mongo.InsertResponse = try await session.run(
                    command: Mongo.Insert.init(collection: collection,
                        elements: Ordinals.init(identifiers: 1 ..< 16)),
                    against: database)
                
                tests.expect(response ==? expected)
            }
        }
        do
        {
            let tests:TestGroup = tests ! "duplicate-id"
            await tests.do
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
                let response:Mongo.InsertResponse = try await session.run(
                    command: Mongo.Insert.init(collection: collection,
                        elements: Ordinals.init(identifiers: 0 ..< 1)),
                    against: database)
                
                tests.expect(response ==? expected)
            }
        }
        do
        {
            let tests:TestGroup = tests ! "ordered"
            await tests.do
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
                let response:Mongo.InsertResponse = try await session.run(
                    command: Mongo.Insert.init(collection: collection,
                        elements: Ordinals.init(identifiers: -8 ..< 32)),
                    against: database)
                
                tests.expect(response ==? expected)
            }
        }
        do
        {
            let tests:TestGroup = tests ! "unordered"
            await tests.do
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
                    command: Mongo.Insert.init(collection: collection,
                        elements: Ordinals.init(identifiers: -16 ..< 32))
                    {
                        $0[.ordered] = false
                    },
                    against: database)
                
                tests.expect(response ==? expected)
            }
        }
    }
}
