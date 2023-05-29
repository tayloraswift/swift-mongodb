import MongoDB
import Testing

func TestCollections(_ tests:TestGroup, bootstrap:Mongo.DriverBootstrap) async
{
    guard let tests:TestGroup = tests / "collections"
    else
    {
        return
    }

    await bootstrap.withTemporaryDatabase(named: "collections-tests", tests: tests)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        let collections:[Mongo.Collection] = (0 ..< 32).map { .init($0.description) }
        let session:Mongo.Session = try await .init(from: pool)

        do
        {
            let tests:TestGroup = tests ! "create"
            await tests.do
            {
                for collection:Mongo.Collection in collections
                {
                    await (tests ! collection.name).do
                    {
                        try await session.run(
                            command: Mongo.Create<Mongo.Collection>.init(collection),
                            against: database)
                    }
                }
            }
        }
        if  let tests:TestGroup = tests / "list-collections" / "bindings"
        {
            await tests.do
            {
                try await session.run(
                    command: Mongo.ListCollections<Mongo.CollectionBinding>.init(stride: 10),
                    against: database)
                {
                    var collections:Set<Mongo.Collection> = .init(collections)
                    for try await batch:[Mongo.CollectionBinding] in $0
                    {
                        tests.expect(true: batch.count <= 10)
                        for binding:Mongo.CollectionBinding in batch
                        {
                            let tests:TestGroup = tests ! binding.collection.name

                            tests.expect(value: collections.remove(binding.collection))
                            tests.expect(binding.type ==? .collection)
                        }
                    }
                    tests.expect(collections **? [])
                }
            }
        }
        if  let tests:TestGroup = tests / "list-collections" / "metadata"
        {
            await tests.do
            {
                try await session.run(
                    command: Mongo.ListCollections<Mongo.CollectionMetadata>.init(stride: 10),
                    against: database)
                {
                    var collections:Set<Mongo.Collection> = .init(collections)
                    for try await batch:[Mongo.CollectionMetadata] in $0
                    {
                        tests.expect(true: batch.count <= 10)
                        for metadata:Mongo.CollectionMetadata in batch
                        {
                            let tests:TestGroup = tests ! metadata.collection.name

                            tests.expect(value: collections.remove(metadata.collection))
                            tests.expect(metadata.type ==? .collection)
                        }
                    }
                    tests.expect(collections **? [])
                }
            }
        }
        if  let tests:TestGroup = tests / "drop"
        {
            for collection:Mongo.Collection in collections
            {
                await (tests ! collection.name).do
                {
                    try await session.run(command: Mongo.Drop.init(collection),
                        against: database)
                }
            }
        }
    }
}
