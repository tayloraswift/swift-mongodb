import MongoDB
import MongoTesting

struct Indexes<Configuration>:MongoTestBattery where Configuration:MongoTestConfiguration
{
    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)
        let collection:Mongo.Collection = "inventory"

        do
        {
            let tests:TestGroup = tests ! "Create"

            await tests.do
            {
                let expected:Mongo.InsertResponse = .init(inserted: 6)
                let response:Mongo.InsertResponse = try await session.run(
                    command: Mongo.Insert.init(collection, encoding: [
                            .init(item: 0,
                                manufacturer: "Lilly Pulitzer",
                                supplier: "Wenzhou Lihui",
                                model: "Adler Mini Skirt"),
                            .init(item: 1,
                                manufacturer: "Lilly Pulitzer",
                                supplier: "Wenzhou Lihui",
                                model: "Paxton Sarong"),
                            .init(item: 2,
                                manufacturer: "Lilly Pulitzer",
                                supplier: "Promise One",
                                model: "Atley Ruffle Cover-up"),
                            .init(item: 3,
                                manufacturer: "Lilly Pulitzer",
                                supplier: "Promise One",
                                model: "Lawless Sleeveless Romper"),
                            .init(item: 0,
                                manufacturer: "Cider",
                                supplier: "Promise One",
                                model: "Floral Bell Sleeve Corset Mini Dress"),
                            .init(item: 1,
                                manufacturer: "Cider",
                                supplier: "Wenzhou Lihui",
                                model: "Glitter O-Ring Backless Halter Top"),
                        ] as [Product]),
                    against: database)

                tests.expect(response ==? expected)
            }
            await tests.do
            {
                let expected:Mongo.CreateIndexesResponse = .init(
                    createdCollectionAutomatically: false,
                    indexesBefore: 1,
                    indexesAfter: 3)
                let response:Mongo.CreateIndexesResponse = try await session.run(
                    command: Mongo.CreateIndexes.init(collection,
                        writeConcern: .majority,
                        indexes:
                        [
                            .init
                            {
                                $0[.unique] = true
                                $0[.name] = "item_manufacturer_model"
                                $0[.key] = .init
                                {
                                    $0["item"] = (+)
                                    $0["manufacturer"] = (+)
                                    $0["model"] = (+)
                                }
                            },
                            .init
                            {
                                $0[.unique] = true
                                $0[.name] = "item_supplier_model"
                                $0[.key] = .init
                                {
                                    $0["item"] = (+)
                                    $0["supplier"] = (+)
                                    $0["model"] = (+)
                                }
                            },
                        ]),
                    against: database)

                tests.expect(response ==? expected)
            }
        }
        if  let tests:TestGroup = tests / "CreateExisting"
        {
            await tests.do
            {
                let expected:Mongo.CreateIndexesResponse = .init(
                    createdCollectionAutomatically: nil,
                    indexesBefore: 3,
                    indexesAfter: 3,
                    note: "all indexes already exist")
                let response:Mongo.CreateIndexesResponse = try await session.run(
                    command: Mongo.CreateIndexes.init(collection,
                        writeConcern: .majority,
                        indexes:
                        [
                            .init
                            {
                                $0[.unique] = true
                                $0[.name] = "item_supplier_model"
                                $0[.key] = .init
                                {
                                    $0["item"] = (+)
                                    $0["supplier"] = (+)
                                    $0["model"] = (+)
                                }
                            },
                        ]),
                    against: database)

                tests.expect(response ==? expected)
            }
        }
        if  let tests:TestGroup = tests / "Drop"
        {
            await tests.do
            {
                try await session.run(
                    command: Mongo.DropIndexes(collection, writeConcern: .majority)
                    {
                        $0[.index] = ["item_manufacturer_model", "item_supplier_model"]
                    },
                    against: database)
            }
        }
    }
}
