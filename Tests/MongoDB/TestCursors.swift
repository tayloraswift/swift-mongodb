import MongoDB
import Testing

func TestCursors(_ tests:TestGroup, bootstrap:Mongo.DriverBootstrap,
    on servers:[Mongo.ReadPreference]) async
{
    guard let tests:TestGroup = tests / "cursors"
    else
    {
        return
    }

    await bootstrap.withTemporaryDatabase(named: "cursor-tests", tests: tests)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        let collection:Mongo.Collection = "ordinals"
        let ordinals:Ordinals = .init(identifiers: 0 ..< 100)

        let initializer:Mongo.Session = try await .init(from: pool)

        do
        {
            let tests:TestGroup = tests ! "initialize"
            await tests.do
            {
                //  We should be able to initialize the test collection with 100 ordinals
                //  of the form:
                //
                //  {_id: 0, value: 0}
                //  {_id: 1, value: 1}
                //
                //   ...
                //
                //  {_id: 99, value: 99}
                let expected:Mongo.InsertResponse = .init(inserted: 100)
                let response:Mongo.InsertResponse = try await initializer.run(
                    command: Mongo.Insert.init(collection: collection,
                        elements: ordinals),
                    against: database,
                    on: .primary)
                
                tests.expect(response ==? expected)
            }
        }

        for (server, name):(Mongo.ReadPreference, String) in zip(servers, ["primary", "b", "c"])
        {
            guard let tests:TestGroup = tests / name / "cursor-cleanup-normal"
            else
            {
                continue
            }

            await tests.do
            {
                //  We should be using a session that is causally-consistent with the
                //  insertion operation at the beginning of this test.
                let session:Mongo.Session = try await .init(from: pool, forking: initializer)
                //  We should be reusing session identifiers.
                tests.expect(await pool.count ==? 2)
                //  We should be able to query the collection for results in batches of
                //  10.
                try await session.run(command: Mongo.Find<Mongo.Cursor<Record<Int64>>>.init(
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
                    if  let iterator:Mongo.CursorIterator = tests.expect(value: $0.cursor)
                    {
                        //  The parameters of the cursor iterator should match the
                        //  parameters used to run the initial query.
                        tests.expect(iterator.namespace.collection ==? collection)
                        tests.expect(iterator.namespace.database ==? database)
                        tests.expect(iterator.preference ==? server)
                        tests.expect(iterator.stride ==? 10)
                        
                        cursor = iterator.id
                    }
                    else
                    {
                        return
                    }

                    //  We should be able to fully iterate the cursor by iterating its
                    //  ``AsyncSequence``
                    var batch:Int = 0
                    for try await elements:[Record<Int64>] in $0
                    {
                        //  We should never observe an empty batch, in fact, every batch
                        //  we receive should contain exactly ten elements.
                        tests.expect(elements.count ==? 10)
                        batch += 1
                    }
                    //  We should have encountered ten batches in total.
                    tests.expect(batch ==? 10)

                    //  The iterator should be [`nil`]() after the last batch is queried,
                    //  and we have exited the loop. The iterator is not guaranteed to be
                    //  [`nil`]() in the last loop iteration, because empty trailing batches
                    //  are not provided to the caller.
                    tests.expect(nil: $0.cursor)

                    let connections:Mongo.ConnectionPool = try await pool.connect(to: server)
                    //  We should never have run more than one concurrent operation with
                    //  this server’s connection pool at a time.
                    tests.expect(await connections.count ==? 1)
                    
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
                    
                    tests.expect(await connections.count ==? 1)

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
                    
                    tests.expect(cursors.alive **? [])
                    tests.expect(cursors.killed **? [])
                    tests.expect(cursors.unknown **? [])
                    tests.expect(cursors.notFound **? [cursor])
                }
            }
        }
        for (server, name):(Mongo.ReadPreference, String) in zip(servers, ["primary", "b", "c"])
        {
            guard let tests:TestGroup = tests / name / "cursor-cleanup-interrupted"
            else
            {
                continue
            }
            for iterations:Int in 0 ... 2
            {
                guard let tests:TestGroup = tests / iterations.description
                else
                {
                    continue
                }

                await tests.do
                {
                    //  We should be using a session that is causally-consistent with the
                    //  insertion operation at the beginning of this test.
                    let session:Mongo.Session = try await .init(from: pool,
                        forking: initializer)
                    let cursor:Mongo.CursorIdentifier? =
                        try await session.run(
                            command: Mongo.Find<Mongo.Cursor<Record<Int64>>>.init(
                                collection: collection,
                                stride: 10),
                            against: database,
                            on: server)
                    {
                        if  iterations > 0
                        {
                            var iteration:Int = 0
                            for try await _:[Record<Int64>] in $0
                            {
                                iteration += 1
                                if iteration == iterations
                                {
                                    break
                                }
                            }
                        }
                        if  let iterator:Mongo.CursorIterator = tests.expect(value: $0.cursor)
                        {
                            //  The parameters of the cursor iterator should match the
                            //  parameters used to run the initial query.
                            tests.expect(iterator.namespace.collection ==? collection)
                            tests.expect(iterator.namespace.database ==? database)
                            tests.expect(iterator.preference ==? server)
                            tests.expect(iterator.stride ==? 10)
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
                        // if the cursor is already dead, killing it manually will return
                        // 'notFound'.
                        tests.expect(cursors.alive **? [])
                        tests.expect(cursors.killed **? [])
                        tests.expect(cursors.unknown **? [])
                        tests.expect(cursors.notFound **? [cursor])
                    }
                }
            }
        }
        for (server, name):(Mongo.ReadPreference, String) in zip(servers, ["primary", "b", "c"])
        {
            guard let tests:TestGroup = tests / name / "cursor-concurrent-commands"
            else
            {
                return
            }

            await tests.do
            {
                let session:Mongo.Session = try await .init(from: pool, forking: initializer)
                try await session.run(
                    command: Mongo.Find<Mongo.Cursor<Record<Int64>>>.init(
                        collection: collection,
                        stride: 10),
                    against: database,
                    on: server)
                {
                    var counter:Int = 0
                    for try await batch:[Record<Int64>] in $0
                    {
                        let tests:TestGroup = tests ! counter.description
                        let names:[Mongo.Database] = try await initializer.run(
                            command: Mongo.ListDatabases.NameOnly.init(),
                            against: .admin,
                            on: server)
                        
                        tests.expect(false: batch.isEmpty)
                        tests.expect(false: names.isEmpty)

                        counter += 1
                    }
                }
            }
        }
    }
}
