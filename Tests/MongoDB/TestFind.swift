import MongoDB
import Testing

func TestFind(_ tests:inout Tests,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<Mongo.Host>) async
{
    await tests.withTemporaryDatabase(name: "collection-find",
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
        await tests.test(name: "single-batch")
        {
            let batch:[Ordinal] = try await pool.run(
                command: Mongo.Find<Ordinal>.SingleBatch.init(
                    collection: collection,
                    limit: 10),
                against: database)

            $0.assert(batch ..? ordinals.prefix(10), name: "elements")
        }
        await tests.test(name: "single-batch-skip")
        {
            let batch:[Ordinal] = try await pool.run(
                command: Mongo.Find<Ordinal>.SingleBatch.init(
                    collection: collection,
                    limit: 7,
                    skip: 5),
                against: database)

            $0.assert(batch ..? ordinals[5 ..< 12], name: "elements")
        }
        await tests.test(name: "single-batch-hint")
        {
            let batch:[Ordinal] = try await pool.run(
                command: Mongo.Find<Ordinal>.SingleBatch.init(
                    collection: collection,
                    limit: 5,
                    skip: 10,
                    hint: .index(.init
                    {
                        $0["_id"] = 1 as Int32
                    })),
                against: database)

            $0.assert(batch ..? ordinals[10 ..< 15], name: "elements")
        }
        await tests.test(name: "single-batch-sort")
        {
            let batch:[Ordinal] = try await pool.run(
                command: Mongo.Find<Ordinal>.SingleBatch.init(
                    collection: collection,
                    limit: 5,
                    skip: 10,
                    sort: .init
                    {
                        $0["ordinal"] = -1 as Int32
                    }),
                against: database)

            $0.assert(batch ..? ordinals[85 ..< 90].reversed(), name: "elements")
        }
        await tests.test(name: "multiple-batches")
        {
            (tests:inout Tests) in

            let session:Mongo.Session = try await .init(from: pool)
            try await session.run(query: Mongo.Find<Ordinal>.init(
                    collection: collection,
                    stride: 10),
                against: database)
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
        await tests.test(name: "filtering")
        {
            (tests:inout Tests) in

            let session:Mongo.Session = try await .init(from: pool)
            try await session.run(query: Mongo.Find<Ordinal>.init(
                    collection: collection,
                    stride: 10,
                    filter: .init
                    {
                        $0["ordinal"] = .init
                        {
                            $0["$mod"] = [3, 0]
                        }
                    }),
                against: database)
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
    }
}
