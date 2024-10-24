import MongoDB
import Testing

@Suite
struct Cursors
{
    let collection:Mongo.Collection = "Ordinals"
    let database:Mongo.Database = "Cursors"

    @Test(arguments: [.single, .replicated] as [any Mongo.TestConfiguration])
    func cursors(_ configuration:any Mongo.TestConfiguration) async throws
    {
        let bootstrap:Mongo.DriverBootstrap = configuration.bootstrap(on: .singleton)
        try await bootstrap.withSessionPool(logger: .init(level: .error))
        {
            try await $0.withTemporaryDatabase(self.database)
            {
                try await self.run(under: configuration, with: $0)
            }
        }
    }

    func run(under configuration:any Mongo.TestConfiguration,
        with pool:Mongo.SessionPool) async throws
    {
        let initializer:Mongo.Session = try await .init(from: pool)
        let ordinals:Ordinals = .init(identifiers: 0 ..< 100)

        do
        {
            //  We should be able to initialize the test self.collection with 100 ordinals
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
                command: Mongo.Insert.init(self.collection, encoding: ordinals),
                against: self.database,
                on: .primary)

            #expect(response == expected)
        }

        for server:Mongo.ReadPreference in configuration.servers
        {
            //  We should be using a session that is causally-consistent with the
            //  insertion operation at the beginning of this test.
            let session:Mongo.Session = try await initializer.fork()
            //  We should be reusing session identifiers.
            #expect(await pool.count == 2)
            //  We should be able to query the self.collection for results in batches of
            //  10.
            try await session.run(
                command: Mongo.Find<Mongo.Cursor<Record<Int64>>>.init(self.collection,
                    stride: 10),
                against: self.database,
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
                do
                {
                    let iterator:Mongo.CursorIterator = try #require($0.cursor)
                    //  The parameters of the cursor iterator should match the
                    //  parameters used to run the initial query.
                    #expect(iterator.namespace.self.collection == self.collection)
                    #expect(iterator.namespace.self.database == self.database)
                    #expect(iterator.preference == server)
                    #expect(iterator.stride == 10)

                    cursor = iterator.id
                }

                //  We should be able to fully iterate the cursor by iterating its
                //  ``AsyncSequence``
                var batch:Int = 0
                for try await elements:[Record<Int64>] in $0
                {
                    //  We should never observe an empty batch, in fact, every batch
                    //  we receive should contain exactly ten elements.
                    #expect(elements.count == 10)
                    batch += 1
                }
                //  We should have encountered ten batches in total.
                #expect(batch == 10)

                //  The iterator should be nil after the last batch is queried,
                //  and we have exited the loop. The iterator is not guaranteed to be
                //  nil in the last loop iteration, because empty trailing batches
                //  are not provided to the caller.
                #expect($0.cursor == nil)

                let connections:Mongo.ConnectionPool = try await pool.connect(to: server)
                //  We should never have run more than one concurrent operation with
                //  this server’s connection pool at a time.
                #expect(await connections.count == 1)

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

                #expect(await connections.count == 1)

                //  We should be able to verify that the server-side cursor is already
                //  dead, by checking if a manual kill command would consider it
                //  “not found”. For this assertion to be meaningful, we should send it
                //  to the same server we ran the original query on, since servers
                //  never have any clue what cursors other servers have.
                let cursors:Mongo.KillCursorsResponse = try await session.run(
                    command: Mongo.KillCursors.init(self.collection, cursors: [cursor]),
                    against: self.database,
                    on: server)

                #expect(cursors.alive == [])
                #expect(cursors.killed == [])
                #expect(cursors.unknown == [])
                #expect(cursors.notFound == [cursor])
            }
        }
        for server:Mongo.ReadPreference in configuration.servers
        {
            for iterations:Int in 0 ... 2
            {
                //  We should be using a session that is causally-consistent with the
                //  insertion operation at the beginning of this test.
                let session:Mongo.Session = try await initializer.fork()
                let cursor:Mongo.CursorIdentifier? =
                    try await session.run(
                        command: Mongo.Find<Mongo.Cursor<Record<Int64>>>.init(self.collection,
                            stride: 10),
                        against: self.database,
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

                    let iterator:Mongo.CursorIterator = try #require($0.cursor)
                    //  The parameters of the cursor iterator should match the
                    //  parameters used to run the initial query.
                    #expect(iterator.namespace.self.collection == self.collection)
                    #expect(iterator.namespace.self.database == self.database)
                    #expect(iterator.preference == server)
                    #expect(iterator.stride == 10)
                    return iterator.id
                }
                if  let cursor:Mongo.CursorIdentifier
                {
                    let cursors:Mongo.KillCursorsResponse = try await session.run(
                        command: Mongo.KillCursors.init(self.collection, cursors: [cursor]),
                        against: self.database,
                        on: server)
                    // if the cursor is already dead, killing it manually will return
                    // 'notFound'.
                    #expect(cursors.alive == [])
                    #expect(cursors.killed == [])
                    #expect(cursors.unknown == [])
                    #expect(cursors.notFound == [cursor])
                }
            }
        }
        for server:Mongo.ReadPreference in configuration.servers
        {
            let session:Mongo.Session = try await initializer.fork()
            try await session.run(
                command: Mongo.Find<Mongo.Cursor<Record<Int64>>>.init(self.collection,
                    stride: 10),
                against: self.database,
                on: server)
            {
                var counter:Int = 0
                for try await batch:[Record<Int64>] in $0
                {
                    let names:[Mongo.Database] = try await initializer.run(
                        command: Mongo.ListDatabases.NameOnly.init(),
                        against: .admin,
                        on: server)

                    #expect(!batch.isEmpty)
                    #expect(!names.isEmpty)

                    counter += 1
                }
            }
        }
    }
}
