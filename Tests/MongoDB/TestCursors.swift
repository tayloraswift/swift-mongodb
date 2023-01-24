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

        let initializer:Mongo.Session = try await .init(from: pool)

        await tests.test(name: "initialize")
        {
            //  We should be able to initialize the test collection with 100 ordinals
            //  of the form:
            //
            //  {_id: 0, ordinal: 0}
            //  {_id: 1, ordinal: 1}
            //
            //   ...
            //
            //  {_id: 99, ordinal: 99}
            let expected:Mongo.InsertResponse = .init(inserted: 100)
            let response:Mongo.InsertResponse = try await initializer.run(
                command: Mongo.Insert<Ordinals>.init(collection: collection,
                    elements: ordinals),
                against: database,
                on: .primary)
            
            $0.assert(response ==? expected, name: "response")
        }

        let servers:[Mongo.ReadPreference] = hosts.count == 1 ?
        [
            //  We should be able to run this test on the primary.
            .primary
        ]
            :
        [
            .primary,
            //  We should be able to run this test on a specific server.
            .nearest(tagSets: [["name": "B"]]),
            //  We should be able to run this test on a secondary.
            .nearest(tagSets: [["name": "C"]]),
        ]

        for (server, name):(Mongo.ReadPreference, String) in zip(servers, ["primary", "b", "c"])
        {
            await tests.test(name: "cursor-cleanup-normal-\(name)")
            {
                (tests:inout Tests) in

                //  We should be using a session that is causally-consistent with the
                //  insertion operation at the beginning of this test.
                let session:Mongo.Session = try await .init(from: pool, forking: initializer)
                //  We should be reusing session identifiers.
                tests.assert(await pool.count ==? 2, name: "session-pool-count")
                //  We should be able to query the collection for results in batches of
                //  10.
                try await session.run(query: Mongo.Find<Ordinal>.init(
                        collection: collection,
                        stride: 10),
                    against: database,
                    on: server)
                {
                    let cursor:Mongo.CursorIdentifier
                    //  We should be able to inspect the cursor iterator before obtaining
                    //  any subsequent batches.
                    //
                    //  We should do this in a nested lexical block, to ensure that the
                    //  iterator’s connection is uniquely-referenced afterwards. This is
                    //  because a ``CursorIterator`` holds a strong reference to its
                    //  pinned connection.
                    if  let iterator:Mongo.CursorIterator = tests.unwrap($0.cursor,
                            name: "iterator")
                    {
                        //  The parameters of the cursor iterator should match the
                        //  parameters used to run the initial query.
                        tests.assert(iterator.namespace.collection ==? collection,
                            name: "collection")
                        tests.assert(iterator.namespace.database ==? database,
                            name: "database")
                        tests.assert(iterator.preference ==? server,
                            name: "preference")
                        tests.assert(iterator.stride ==? 10,
                            name: "batch-stride")
                        
                        cursor = iterator.id
                    }
                    else
                    {
                        return
                    }

                    //  We should be able to fully iterate the cursor by iterating its
                    //  ``AsyncSequence``
                    var batch:Int = 0
                    for try await elements:[Ordinal] in $0
                    {
                        //  We should never observe an empty batch, in fact, every batch
                        //  we receive should contain exactly ten elements.
                        tests.assert(elements.count ==? 10, name: "batch-elements-count")
                        batch += 1
                    }
                    //  We should have encountered ten batches in total.
                    tests.assert(batch ==? 10, name: "batch-count")

                    //  The iterator should be [`nil`]() after the last batch is queried,
                    //  and we have exited the loop. The iterator is not guaranteed to be
                    //  [`nil`]() in the last loop iteration, because empty trailing batches
                    //  are not provided to the caller.
                    tests.assert($0.cursor == nil, name: "iterator-nil")

                    let connections:Mongo.ConnectionPool = try await pool.connect(to: server)
                    //  We should never have run more than one concurrent operation with
                    //  this server’s connection pool at a time.
                    tests.assert(await connections.count ==? 1,
                        name: "connection-pool-count-before")
                    
                    //  We should be able to reuse the batch sequence’s connection after
                    //  finishing iteration, even though we are still inside the query
                    //  closure. In other words, we should be able to obtain a second
                    //  connection to this server from inside this closure, without it
                    //  being considered a concurrent operation.
                    do
                    {
                        let connection:Mongo.Connection = try await .init(from: connections,
                            by: .now.advanced(by: .milliseconds(500)))

                        //  We should limit the lifetime of the test connection to this
                        //  do block, to allow the next command to reuse it.
                        let _:Mongo.Connection = connection
                    }
                    
                    tests.assert(await connections.count ==? 1,
                        name: "connection-pool-count-after")

                    //  We should be able to verify that the server-side cursor is already
                    //  dead, by checking if a manual kill command would consider it
                    //  “not found”. For this assertion to be meaningful, we should send it
                    //  to the same server we ran the original query on, since servers
                    //  never have any clue what cursors other servers have.
                    let cursors:Mongo.KillCursorsResponse = try await session.run(
                        command: Mongo.KillCursors.init([cursor], 
                            collection: collection),
                        against: database,
                        on: server)
                    
                    tests.assert(cursors.alive **? [], name: "cursors-alive")
                    tests.assert(cursors.killed **? [], name: "cursors-killed")
                    tests.assert(cursors.unknown **? [], name: "cursors-unknown")
                    tests.assert(cursors.notFound **? [cursor],
                        name: "cursors-not-found")
                }
            }
            for iterations:Int in 0 ... 2
            {
                await tests.test(
                    name: "cursor-cleanup-interrupted-\(name)-\(iterations)-iterations")
                {
                    (tests:inout Tests) in

                    //  We should be using a session that is causally-consistent with the
                    //  insertion operation at the beginning of this test.
                    let session:Mongo.Session = try await .init(from: pool,
                        forking: initializer)
                    let cursor:Mongo.CursorIdentifier? =
                        try await session.run(query: Mongo.Find<Ordinal>.init(
                                collection: collection,
                                stride: 10),
                            against: database,
                            on: server)
                    {
                        if  iterations > 0
                        {
                            var iteration:Int = 0
                            for try await _:[Ordinal] in $0
                            {
                                iteration += 1
                                if iteration == iterations
                                {
                                    break
                                }
                            }
                        }
                        if  let iterator:Mongo.CursorIterator = tests.unwrap($0.cursor,
                                name: "iterator")
                        {
                            //  The parameters of the cursor iterator should match the
                            //  parameters used to run the initial query.
                            tests.assert(iterator.namespace.collection ==? collection,
                                name: "collection")
                            tests.assert(iterator.namespace.database ==? database,
                                name: "database")
                            tests.assert(iterator.preference ==? server,
                                name: "preference")
                            tests.assert(iterator.stride ==? 10,
                                name: "batch-stride")
                            return iterator.id
                        }
                        else
                        {
                            return nil
                        }
                    }
                    if  let cursor:Mongo.CursorIdentifier
                    {
                        let cursors:Mongo.KillCursorsResponse = try await session.run(
                            command: Mongo.KillCursors.init([cursor], 
                                collection: collection),
                            against: database,
                            on: server)
                        // if the cursor is already dead, killing it manually will return 'notFound'.
                        tests.assert(cursors.alive **? [], name: "cursors-alive")
                        tests.assert(cursors.killed **? [], name: "cursors-killed")
                        tests.assert(cursors.unknown **? [], name: "cursors-unknown")
                        tests.assert(cursors.notFound **? [cursor], name: "cursors-not-found")
                    }
                }
            }
            await tests.test(name: "cursor-connection-pooling")
            {
                (tests:inout Tests) in

                let session:Mongo.Session = try await .init(from: pool, forking: initializer)
                try await session.run(
                    query: Mongo.Find<Ordinal>.init(collection: collection, stride: 10),
                    against: database,
                    on: server)
                {
                    var counter:Int = 0
                    for try await batch:[Ordinal] in $0
                    {
                        let names:[Mongo.Database] = try await initializer.run(
                            command: Mongo.ListDatabases.NameOnly.init(),
                            against: .admin,
                            on: server)
                        
                        tests.assert(!batch.isEmpty, name: "stream.\(counter)")
                        tests.assert(!names.isEmpty, name: "list-databases.\(counter)")

                        counter += 1
                    }
                }
            }
        }
    }
}
