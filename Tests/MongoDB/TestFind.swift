import MongoDB
import MongoTopology
import Testing

func TestFind(_ tests:inout Tests,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<MongoTopology.Host>) async
{
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
    }
}
