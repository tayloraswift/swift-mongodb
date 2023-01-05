import MongoDB
import MongoTopology
import Testing

func TestCursors(_ tests:inout Tests,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<MongoTopology.Host>) async
{
    await tests.test(with: DatabaseEnvironment.init(bootstrap: bootstrap,
        database: "cursors",
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
                            tests.unwrap($0.current.next, name: "cursor-id")
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

            let cursor:Mongo.CursorIdentifier? =
                try await session.run(
                    query: Mongo.Find<Ordinal>.init(collection: collection, stride: 10),
                    against: context.database)
            {
                if  let cursor:Mongo.CursorIdentifier = tests.unwrap($0.current.next,
                        name: "cursor-id")
                {
                    tests.assert($0.database ==? context.database,
                        name: "cursor-database-name")
                    tests.assert($0.collection ==? collection,
                        name: "cursor-collection-name")
                    return cursor
                }
                else
                {
                    return nil
                }
            }
            guard let cursor:Mongo.CursorIdentifier
            else
            {
                return
            }

            let cursors:Mongo.KillCursors.Response = try await session.run(
                command: Mongo.KillCursors.init([cursor], 
                    collection: collection),
                against: context.database)
            // if the cursor is already dead, killing it manually will return 'notFound'.
            tests.assert(cursors.alive **? [], name: "cursors-alive")
            tests.assert(cursors.killed **? [], name: "cursors-killed")
            tests.assert(cursors.unknown **? [], name: "cursors-unknown")
            tests.assert(cursors.notFound **? [cursor], name: "cursors-not-found")
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
