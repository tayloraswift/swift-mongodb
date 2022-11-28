import MongoDB
import Testing

extension Tests
{
    mutating
    func find(cluster:Mongo.Cluster, database:Mongo.Database, builtin:[Mongo.Database]) async
    {
        let collection:Mongo.Collection = "ordinals"
        let ordinals:Ordinals = .init(identifiers: 0 ..< 100)

        await self.do(name: "initialize")
        {
            let expected:Mongo.InsertResponse = .init(inserted: 100)
            let response:Mongo.InsertResponse = try await cluster.run(
                command: Mongo.Insert<Ordinals>.init(collection: collection,
                    elements: ordinals),
                against: database)
            
            $0.assert(response ==? expected, name: "response")
        }
        // await tests.do(name: "single-batch")
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
        await self.do(name: "multiple-batches")
        {
            let session:Mongo.Session = try await cluster.session(on: .any)

            var expected:Ordinals.Iterator = ordinals.makeIterator()
            for try await batch:[Ordinal] in try await session.run(
                query: Mongo.Find<Ordinal>.init(collection: collection,
                    returning: 10),
                against: database)
            {
                for returned:Ordinal in batch
                {
                    if  let expected:Ordinal = $0.unwrap(expected.next(),
                            name: "next-expected")
                    {
                        $0.assert(returned == expected, name: expected.id.description)
                    }
                }
            }
            $0.assert(expected.next() == nil, name: "next-returned")
        }
        await self.do(name: "filtering")
        {
            let session:Mongo.Session = try await cluster.session(on: .any)
            var expected:Array<Ordinal>.Iterator = 
                ordinals.filter { $0.value % 3 == 0 }.makeIterator()
            for try await batch:[Ordinal] in try await session.run(
                query: Mongo.Find<Ordinal>.init(collection: collection,
                    returning: 10,
                    filter: .init
                    {
                        $0["ordinal"] = ["$mod": [3, 0]]
                    }),
                against: database)
            {
                for returned:Ordinal in batch
                {
                    if  let expected:Ordinal = $0.unwrap(expected.next(),
                            name: "next-expected")
                    {
                        $0.assert(returned == expected, name: expected.id.description)
                    }
                }
            }
            $0.assert(expected.next() == nil, name: "next-returned")
        }
        await self.do(name: "cursor-cleanup-normal")
        {
            let session:Mongo.Session = try await cluster.session(on: .any)
            let stream:Mongo.Stream<Ordinal> = try await session.run(
                query: Mongo.Find<Ordinal>.init(collection: collection,
                    returning: 10),
                against: database)
            guard   let cursor:(id:Mongo.CursorIdentifier, namespace:Mongo.Namespace) =
                        $0.unwrap(stream.cursor, name: "cursor-id")
            else
            {
                return
            }
            for try await _:[Ordinal] in stream
            {
            }
            let cursors:Mongo.KillCursors.Response = try await session.run(
                command: Mongo.KillCursors.init([cursor.id], 
                    collection: cursor.namespace.collection),
                against: cursor.namespace.database)
            // if the cursor is already dead, killing it manually will return 'notFound'.
            $0.assert(cursors.alive **? [], name: "cursors-alive")
            $0.assert(cursors.killed **? [], name: "cursors-killed")
            $0.assert(cursors.unknown **? [], name: "cursors-unknown")
            $0.assert(cursors.notFound **? [cursor.id], name: "cursors-not-found")
        }
        await self.do(name: "cursor-cleanup-interruption")
        {
            let session:Mongo.Session = try await cluster.session(on: .any)
            // the ``Mongo.Stream`` will live until the end of its lexical block.
            // so we need to scope it in a `do` block to force stream deinitialization
            // on iterator interruption.
            let cursor:(id:Mongo.CursorIdentifier, namespace:Mongo.Namespace)?
            do
            {
                let stream:Mongo.Stream<Ordinal> = try await session.run(
                    query: Mongo.Find<Ordinal>.init(collection: collection,
                        returning: 10),
                    against: database)
                cursor = $0.unwrap(stream.cursor, name: "cursor-id")
                for try await _:[Ordinal] in stream
                {
                    break
                }
            }
            guard let cursor:(id:Mongo.CursorIdentifier, namespace:Mongo.Namespace)
            else
            {
                return
            }
            // give the server 100 ms to process the automatic kill-cursors operation,
            // otherwise the kill-cursors probe might outrun the automated operation.
            try await Task.sleep(for: .milliseconds(100))
            let cursors:Mongo.KillCursors.Response = try await session.run(
                command: Mongo.KillCursors.init([cursor.id], 
                    collection: cursor.namespace.collection),
                against: cursor.namespace.database)
            // if the cursor is already dead, killing it manually will return 'notFound'.
            $0.assert(cursors.alive **? [], name: "cursors-alive")
            $0.assert(cursors.killed **? [], name: "cursors-killed")
            $0.assert(cursors.unknown **? [], name: "cursors-unknown")
            $0.assert(cursors.notFound **? [cursor.id], name: "cursors-not-found")
        }
        await self.do(name: "connection-multiplexing")
        {
            let session:Mongo.Session = try await cluster.session(on: .any)
            var counter:Int = 0
            for try await batch:[Ordinal] in try await session.run(
                query: Mongo.Find<Ordinal>.init(collection: collection,
                    returning: 10),
                against: database)
            {
                let names:[Mongo.Database] = try await cluster.run(
                    command: Mongo.ListDatabases.NameOnly.init())
                $0.assert(!batch.isEmpty, name: "stream.\(counter)")
                $0.assert(!names.isEmpty, name: "list-databases.\(counter)")

                counter += 1
            }
        }
    }
}
