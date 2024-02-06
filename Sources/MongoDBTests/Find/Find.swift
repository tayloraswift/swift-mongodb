import MongoDB
import MongoTesting

struct Find<Configuration>:MongoTestBattery where Configuration:MongoTestConfiguration
{
    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let collection:Mongo.Collection = "ordinals"
        let ordinals:Ordinals = .init(identifiers: 0 ..< 100)

        do
        {
            let tests:TestGroup = tests ! "initialize"
            await tests.do
            {
                let expected:Mongo.InsertResponse = .init(inserted: 100)
                let response:Mongo.InsertResponse = try await pool.run(
                    command: Mongo.Insert.init(collection, encoding: ordinals),
                    against: database)

                tests.expect(response ==? expected)
            }
        }
        if  let tests:TestGroup = tests / "single-batch"
        {
            await tests.do
            {
                let batch:[Record<Int64>] = try await pool.run(
                    command: Mongo.Find<Mongo.SingleBatch<Record<Int64>>>.init(collection,
                        limit: 10),
                    against: database)

                tests.expect(batch ..? ordinals.prefix(10))
            }
        }
        if  let tests:TestGroup = tests / "single-batch-skip"
        {
            await tests.do
            {
                let batch:[Record<Int64>] = try await pool.run(
                    command: Mongo.Find<Mongo.SingleBatch<Record<Int64>>>.init(collection,
                        limit: 7,
                        skip: 5),
                    against: database)

                tests.expect(batch ..? ordinals[5 ..< 12])
            }
        }
        if  let tests:TestGroup = tests / "single-batch-hint"
        {
            await tests.do
            {
                let batch:[Record<Int64>] = try await pool.run(
                    command: Mongo.Find<Mongo.SingleBatch<Record<Int64>>>.init(collection,
                        limit: 5,
                        skip: 10)
                    {
                        $0[.hint] = .init
                        {
                            $0["_id"] = (+)
                        }
                    },
                    against: database)

                tests.expect(batch ..? ordinals[10 ..< 15])
            }
        }
        if  let tests:TestGroup = tests / "single-batch-sort"
        {
            await tests.do
            {
                let batch:[Record<Int64>] = try await pool.run(
                    command: Mongo.Find<Mongo.SingleBatch<Record<Int64>>>.init(collection,
                        limit: 5,
                        skip: 10)
                    {
                        $0[.sort] = .init
                        {
                            $0["value"] = (-)
                        }
                    },
                    against: database)

                tests.expect(batch ..? ordinals[85 ..< 90].reversed())
            }
        }
        if  let tests:TestGroup = tests / "multiple-batches"
        {
            await tests.do
            {
                let session:Mongo.Session = try await .init(from: pool)
                try await session.run(
                    command: Mongo.Find<Mongo.Cursor<Record<Int64>>>.init(collection,
                        stride: 10),
                    against: database)
                {
                    var expected:Ordinals.Iterator = ordinals.makeIterator()
                    for try await batch:[Record<Int64>] in $0
                    {
                        for returned:Record<Int64> in batch
                        {
                            if  let expected:Record<Int64> = tests.expect(
                                    value: expected.next())
                            {
                                tests.expect(returned ==? expected)
                            }
                        }
                    }
                    tests.expect(nil: expected.next())
                }
            }
        }
        if  let tests:TestGroup = tests / "filtering"
        {
            await tests.do
            {
                let session:Mongo.Session = try await .init(from: pool)
                try await session.run(
                    command: Mongo.Find<Mongo.Cursor<Record<Int64>>>.init(collection,
                        stride: 10)
                    {
                        $0[.filter] = .init
                        {
                            $0["value"] { $0[.mod] = (by: 3, is: 0) }
                        }
                    },
                    against: database)
                {
                    var expected:Array<Record<Int64>>.Iterator =
                        ordinals.filter { $0.value % 3 == 0 }.makeIterator()
                    for try await batch:[Record<Int64>] in $0
                    {
                        for returned:Record<Int64> in batch
                        {
                            if  let expected:Record<Int64> = tests.expect(
                                    value: expected.next())
                            {
                                tests.expect(returned ==? expected)
                            }
                        }
                    }
                    tests.expect(nil: expected.next())
                }
            }
        }
        if  let tests:TestGroup = tests / "projection"
        {
            await tests.do
            {
                let session:Mongo.Session = try await .init(from: pool)
                try await session.run(
                    command: Mongo.Find<Mongo.Cursor<Record<Int64>>>.init(collection,
                        stride: 10)
                    {
                        $0[.projection] = .init
                        {
                            $0["_id"] = 1 as Int32
                            $0["value"] = .expr
                            {
                                $0[.add] = ("$value", 5)
                            }
                        }
                    },
                    against: database)
                {
                    var expected:Ordinals.Iterator = Ordinals.init(
                        identifiers: 0 ..< 100,
                        start: 5).makeIterator()
                    for try await batch:[Record<Int64>] in $0
                    {
                        for returned:Record<Int64> in batch
                        {
                            if  let expected:Record<Int64> = tests.expect(
                                    value: expected.next())
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
