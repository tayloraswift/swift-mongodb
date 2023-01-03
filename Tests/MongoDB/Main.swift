import NIOPosix
import MongoDB
import MongoTopology
import Testing

@main
enum Main:AsyncTests
{
    static
    func run(tests:inout Tests) async
    {
        let single:MongoTopology.Host = .init(name: "mongo-single", port: 27017)
        let members:Set<MongoTopology.Host> =
        [
            .init(name: "mongo-1", port: 27017),
            .init(name: "mongo-2", port: 27017),
            .init(name: "mongo-3", port: 27017),
        ]

        let executor:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        print("running tests for single topology (host: \(single))")
        await self.run(tests: &tests, bootstrap: .init(
                commandTimeout: .seconds(10),
                credentials: .init(authentication: .sasl(.sha256),
                    username: "root",
                    password: "80085"),
                executor: executor),
            hosts: [single],
            on: executor)
        
        print("running tests for replicated topology (hosts: \(members))")
        await self.run(tests: &tests, bootstrap: .init(
                commandTimeout: .seconds(10),
                credentials: nil,
                executor: executor),
            hosts: members,
            on: executor)
    }
    static
    func run(tests:inout Tests,
        bootstrap:Mongo.DriverBootstrap,
        hosts:Set<MongoTopology.Host>,
        on executor:MultiThreadedEventLoopGroup) async
    {
        await tests.test(with: DatabaseEnvironment.init(bootstrap: bootstrap,
            database: "databases",
            hosts: hosts))
        {
            (tests:inout Tests, context:DatabaseEnvironment.Context) in

            await tests.test(name: "create-database-by-collection")
            {
                _ in try await context.pool.run(
                    command: Mongo.Create.init(collection: "placeholder"), 
                    against: context.database)
            }

            await tests.test(name: "list-database-names")
            {
                let names:[Mongo.Database] = try await context.pool.run(
                    command: Mongo.ListDatabases.NameOnly.init())
                $0.assert(names.contains(context.database),
                    name: "contains")
            }

            await tests.test(name: "list-databases")
            {
                let (size, databases):(Int, [Mongo.DatabaseMetadata]) = try await context.pool.run(
                    command: Mongo.ListDatabases.init())
                $0.assert(size > 0,
                    name: "nonzero-size")
                $0.assert(databases.contains { $0.database == context.database },
                    name: "contains")
            }
        }
        
        await tests.test(with: DatabaseEnvironment.init(bootstrap: bootstrap,
            database: "collection-insert",
            hosts: hosts))
        {
            (tests:inout Tests, context:DatabaseEnvironment.Context) in

            let collection:Mongo.Collection = "ordinals"

            await tests.test(name: "insert-one")
            {
                let expected:Mongo.InsertResponse = .init(inserted: 1)
                let response:Mongo.InsertResponse = try await context.pool.run(
                    command: Mongo.Insert<Ordinals>.init(collection: collection,
                        elements: .init(identifiers: 0 ..< 1)),
                    against: context.database)
                
                $0.assert(response ==? expected, name: "response")
            }

            await tests.test(name: "insert-multiple")
            {
                let expected:Mongo.InsertResponse = .init(inserted: 15)
                let response:Mongo.InsertResponse = try await context.pool.run(
                    command: Mongo.Insert<Ordinals>.init(collection: collection,
                        elements: .init(identifiers: 1 ..< 16)),
                    against: context.database)
                
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
                            \(context.database).\(collection) index: _id_ dup key: { _id: 0 }
                            """,
                            code: 11000),
                    ])
                let response:Mongo.InsertResponse = try await context.pool.run(
                    command: Mongo.Insert<Ordinals>.init(collection: collection,
                        elements: .init(identifiers: 0 ..< 1)),
                    against: context.database)
                
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
                            \(context.database).\(collection) index: _id_ dup key: { _id: 0 }
                            """,
                            code: 11000),
                    ])
                let response:Mongo.InsertResponse = try await context.pool.run(
                    command: Mongo.Insert<Ordinals>.init(collection: collection,
                        elements: .init(identifiers: -8 ..< 32)),
                    against: context.database)
                
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
                            \(context.database).\(collection) index: _id_ dup key: { _id: \($0 - 16) }
                            """,
                            code: 11000)
                    })
                let response:Mongo.InsertResponse = try await context.pool.run(
                    command: Mongo.Insert<Ordinals>.init(collection: collection,
                        elements: .init(identifiers: -16 ..< 32),
                        ordered: false),
                    against: context.database)
                
                $0.assert(response ==? expected, name: "response")
            }
        }
        
        await tests.test(with: DatabaseEnvironment.init(bootstrap: bootstrap,
            database: "collection-find",
            hosts: hosts))
        {
            (tests:inout Tests, context:DatabaseEnvironment.Context) in

            let collection:Mongo.Collection = "ordinals"
            let ordinals:Ordinals = .init(identifiers: 0 ..< 100)

            await tests.test(name: "initialize")
            {
                let expected:Mongo.InsertResponse = .init(inserted: 100)
                let response:Mongo.InsertResponse = try await context.pool.run(
                    command: Mongo.Insert<Ordinals>.init(collection: collection,
                        elements: ordinals),
                    against: context.database)
                
                $0.assert(response ==? expected, name: "response")
            }
            // await tests.test(name: "single-batch")
            // {
            //     let expected:Mongo.Cursor<Ordinal> = .init(id: 0,
            //         namespace: .init(database, collection),
            //         elements: [Ordinal].init(ordinals.prefix(10)))
            //     let cursor:Mongo.Cursor<Ordinal> = try await cluster.run(
            //         command: Mongo.Find<Ordinal>.init(collection: collection,
            //             returning: .batch(of: 10)),
            //         against: database)

            //     $0.assert(cursor ==? expected, name: "cursor")
            // }
            await tests.test(name: "multiple-batches")
            {
                (tests:inout Tests) in

                try await context.pool.withSession
                {
                    try await $0.run(query: Mongo.Find<Ordinal>.init(
                            collection: collection,
                            stride: 10),
                        against: context.database)
                    {
                        var expected:Ordinals.Iterator = ordinals.makeIterator()
                        for try await batch:[Ordinal] in $0
                        {
                            for returned:Ordinal in batch
                            {
                                if  let expected:Ordinal = tests.unwrap(expected.next(),
                                        name: "next-expected")
                                {
                                    tests.assert(returned == expected,
                                        name: expected.id.description)
                                }
                            }
                        }
                        tests.assert(expected.next() == nil, name: "next-returned")
                    }
                }
            }
            await tests.test(with: SessionEnvironment.init(name: "filtering",
                pool: context.pool))
            {
                (tests:inout Tests, session:Mongo.Session) in
            
                try await session.run(query: Mongo.Find<Ordinal>.init(
                        collection: collection,
                        stride: 10,
                        filter: .init
                        {
                            $0["ordinal"] = ["$mod": [3, 0]]
                        }),
                    against: context.database)
                {
                    var expected:Array<Ordinal>.Iterator = 
                        ordinals.filter { $0.value % 3 == 0 }.makeIterator()
                    for try await batch:[Ordinal] in $0
                    {
                        for returned:Ordinal in batch
                        {
                            if  let expected:Ordinal = tests.unwrap(expected.next(),
                                    name: "next-expected")
                            {
                                tests.assert(returned == expected, name: expected.id.description)
                            }
                        }
                    }
                    tests.assert(expected.next() == nil, name: "next-returned")
                }
            }
            await tests.test(with: SessionEnvironment.init(name: "cursor-cleanup-normal",
                pool: context.pool))
            {
                (tests:inout Tests, session:Mongo.Session) in

                try await session.run(query: Mongo.Find<Ordinal>.init(
                        collection: collection,
                        stride: 10),
                    against: context.database)
                {
                    guard   let cursor:Mongo.CursorIdentifier =
                                tests.unwrap(.init($0.cursor.next), name: "cursor-id")
                    else
                    {
                        return
                    }
                    for try await _:[Ordinal] in $0
                    {
                    }
                    let cursors:Mongo.KillCursors.Response = try await session.run(
                        command: Mongo.KillCursors.init([cursor], 
                            collection: $0.collection),
                        against: $0.database)
                    // if the cursor is already dead, killing it manually will return 'notFound'.
                    tests.assert(cursors.alive **? [], name: "cursors-alive")
                    tests.assert(cursors.killed **? [], name: "cursors-killed")
                    tests.assert(cursors.unknown **? [], name: "cursors-unknown")
                    tests.assert(cursors.notFound **? [cursor], name: "cursors-not-found")
                }
            }
            await tests.test(with: SessionEnvironment.init(name: "cursor-cleanup-interruption",
                pool: context.pool))
            {
                (tests:inout Tests, session:Mongo.Session) in

                let cursor:(id:Mongo.CursorIdentifier, namespace:Mongo.Namespace)? =
                    try await session.run(
                        query: Mongo.Find<Ordinal>.init(collection: collection, stride: 10),
                        against: context.database)
                {
                    if  let cursor:Mongo.CursorIdentifier = tests.unwrap(.init($0.cursor.next),
                            name: "cursor-id")
                    {
                        return (cursor, $0.namespace)
                    }
                    else
                    {
                        return nil
                    }
                }
                guard let cursor:(id:Mongo.CursorIdentifier, namespace:Mongo.Namespace)
                else
                {
                    return
                }

                let cursors:Mongo.KillCursors.Response = try await session.run(
                    command: Mongo.KillCursors.init([cursor.id], 
                        collection: cursor.namespace.collection),
                    against: cursor.namespace.database)
                // if the cursor is already dead, killing it manually will return 'notFound'.
                tests.assert(cursors.alive **? [], name: "cursors-alive")
                tests.assert(cursors.killed **? [], name: "cursors-killed")
                tests.assert(cursors.unknown **? [], name: "cursors-unknown")
                tests.assert(cursors.notFound **? [cursor.id], name: "cursors-not-found")
            }
            await tests.test(with: SessionEnvironment.init(name: "connection-multiplexing",
                pool: context.pool))
            {
                (tests:inout Tests, session:Mongo.Session) in

                try await session.run(
                    query: Mongo.Find<Ordinal>.init(collection: collection, stride: 10),
                    against: context.database)
                {
                    var counter:Int = 0
                    for try await batch:[Ordinal] in $0
                    {
                        let names:[Mongo.Database] = try await context.pool.run(
                            command: Mongo.ListDatabases.NameOnly.init())
                        tests.assert(!batch.isEmpty, name: "stream.\(counter)")
                        tests.assert(!names.isEmpty, name: "list-databases.\(counter)")

                        counter += 1
                    }
                }
            }
        }
    }
}
