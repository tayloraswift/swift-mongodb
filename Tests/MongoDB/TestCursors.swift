import MongoDB
import Testing

func TestCursors(_ tests:inout Tests,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<Mongo.Host>) async
{
    await tests.withTemporaryDatabase(name: "cursors",
        bootstrap: bootstrap,
        hosts: hosts)
    {
        (tests:inout Tests, pool:Mongo.SessionPool, database:Mongo.Database) in

        let collection:Mongo.Collection = "ordinals"
        let ordinals:Ordinals = .init(identifiers: 0 ..< 100)

        await tests.test(name: "initialize")
        {
            let expected:Mongo.InsertResponse = .init(inserted: 100)
            let response:Mongo.InsertResponse = try await pool.run(
                command: Mongo.Insert<Ordinals>.init(collection: collection,
                    elements: ordinals),
                against: database)
            
            $0.assert(response ==? expected, name: "response")
        }
        
        await tests.test(name: "cursor-cleanup-normal")
        {
            (tests:inout Tests) in

            let session:Mongo.Session = try await .init(from: pool)
            try await session.run(query: Mongo.Find<Ordinal>.init(
                    collection: collection,
                    stride: 10),
                against: database)
            {
                guard   let cursor:Mongo.CursorIterator =
                            tests.unwrap($0.cursor, name: "cursor-id")
                else
                {
                    return
                }
                for try await _:[Ordinal] in $0
                {
                }
                let cursors:Mongo.KillCursorsResponse = try await session.run(
                    command: Mongo.KillCursors.init([cursor.id], 
                        collection: cursor.namespace.collection),
                    against: cursor.namespace.database)
                // if the cursor is already dead, killing it manually will return 'notFound'.
                tests.assert(cursors.alive **? [], name: "cursors-alive")
                tests.assert(cursors.killed **? [], name: "cursors-killed")
                tests.assert(cursors.unknown **? [], name: "cursors-unknown")
                tests.assert(cursors.notFound **? [cursor.id], name: "cursors-not-found")
            }
        }
        await tests.test(name: "cursor-cleanup-interruption")
        {
            (tests:inout Tests) in

            let session:Mongo.Session = try await .init(from: pool)
            let cursor:Mongo.CursorIdentifier? =
                try await session.run(
                    query: Mongo.Find<Ordinal>.init(collection: collection, stride: 10),
                    against: database)
            {
                if  let cursor:Mongo.CursorIterator = tests.unwrap($0.cursor,
                        name: "cursor-id")
                {
                    tests.assert(cursor.namespace.database ==? database,
                        name: "cursor-database-name")
                    tests.assert(cursor.namespace.collection ==? collection,
                        name: "cursor-collection-name")
                    return cursor.id
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

            let cursors:Mongo.KillCursorsResponse = try await session.run(
                command: Mongo.KillCursors.init([cursor], 
                    collection: collection),
                against: database)
            // if the cursor is already dead, killing it manually will return 'notFound'.
            tests.assert(cursors.alive **? [], name: "cursors-alive")
            tests.assert(cursors.killed **? [], name: "cursors-killed")
            tests.assert(cursors.unknown **? [], name: "cursors-unknown")
            tests.assert(cursors.notFound **? [cursor], name: "cursors-not-found")
        }
        await tests.test(name: "connection-multiplexing")
        {
            (tests:inout Tests) in

            let session:Mongo.Session = try await .init(from: pool)
            try await session.run(
                query: Mongo.Find<Ordinal>.init(collection: collection, stride: 10),
                against: database)
            {
                var counter:Int = 0
                for try await batch:[Ordinal] in $0
                {
                    let names:[Mongo.Database] = try await pool.run(
                        command: Mongo.ListDatabases.NameOnly.init(),
                        against: .admin)
                    tests.assert(!batch.isEmpty, name: "stream.\(counter)")
                    tests.assert(!names.isEmpty, name: "list-databases.\(counter)")

                    counter += 1
                }
            }
        }
    }
}
