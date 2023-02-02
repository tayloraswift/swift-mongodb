import MongoDB
import Testing

func TestFind(_ tests:TestGroup,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<Mongo.Host>) async
{
    let tests:TestGroup = tests / "find"

    await tests.withTemporaryDatabase(named: "find-tests",
        bootstrap: bootstrap,
        hosts: hosts)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        let collection:Mongo.Collection = "ordinals"
        let ordinals:Ordinals = .init(identifiers: 0 ..< 100)

        do
        {
            let tests:TestGroup = tests / "initialize"
            await tests.do
            {
                let expected:Mongo.InsertResponse = .init(inserted: 100)
                let response:Mongo.InsertResponse = try await pool.run(
                    command: Mongo.Insert<Ordinals>.init(collection: collection,
                        elements: ordinals),
                    against: database)
                
                tests.expect(response ==? expected)
            }
        }
        do
        {
            let tests:TestGroup = tests / "single-batch"
            await tests.do
            {
                let batch:[Ordinal] = try await pool.run(
                    command: Mongo.Find<Ordinal>.SingleBatch.init(
                        collection: collection,
                        limit: 10),
                    against: database)

                tests.expect(batch ..? ordinals.prefix(10))
            }
        }
        do
        {
            let tests:TestGroup = tests / "single-batch-skip"
            await tests.do
            {
                let batch:[Ordinal] = try await pool.run(
                    command: Mongo.Find<Ordinal>.SingleBatch.init(
                        collection: collection,
                        limit: 7,
                        skip: 5),
                    against: database)

                tests.expect(batch ..? ordinals[5 ..< 12])
            }
        }
        do
        {
            let tests:TestGroup = tests / "single-batch-hint"
            await tests.do
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

                tests.expect(batch ..? ordinals[10 ..< 15])
            }
        }
        do
        {
            let tests:TestGroup = tests / "single-batch-sort"
            await tests.do
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

                tests.expect(batch ..? ordinals[85 ..< 90].reversed())
            }
        }
        do
        {
            let tests:TestGroup = tests / "multiple-batches"
            await tests.do
            {
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
                            if  let expected:Ordinal = tests.expect(value: expected.next())
                            {
                                tests.expect(returned ==? expected)
                            }
                        }
                    }
                    tests.expect(nil: expected.next())
                }
            }
        }
        do
        {
            let tests:TestGroup = tests / "filtering"
            await tests.do
            {
                let session:Mongo.Session = try await .init(from: pool)
                try await session.run(query: Mongo.Find<Ordinal>.init(
                        collection: collection,
                        stride: 10,
                        filter: .init
                        {
                            $0["ordinal"] = .init
                            {
                                $0[.mod] = (by: 3, is: 0)
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
                            if  let expected:Ordinal = tests.expect(value: expected.next())
                            {
                                tests.expect(returned ==? expected)
                            }
                        }
                    }
                    tests.expect(nil: expected.next())
                }
            }
        }
        do
        {
            let tests:TestGroup = tests / "projection"
            await tests.do
            {
                let session:Mongo.Session = try await .init(from: pool)
                try await session.run(query: Mongo.Find<Ordinal>.init(
                        collection: collection,
                        stride: 10,
                        projection: .init
                        {
                            $0["_id"] = 1 as Int32
                            $0["ordinal"] = .init
                            {
                                $0[.add] = ("$ordinal", 5)
                            }
                        }),
                    against: database)
                {
                    var expected:Ordinals.Iterator = Ordinals.init(
                        identifiers: 0 ..< 100,
                        start: 5).makeIterator()
                    for try await batch:[Ordinal] in $0
                    {
                        for returned:Ordinal in batch
                        {
                            if  let expected:Ordinal = tests.expect(value: expected.next())
                            {
                                tests.expect(returned ==? expected)
                            }
                        }
                    }
                    tests.expect(nil: expected.next())
                }
            }
        }
    }
}
