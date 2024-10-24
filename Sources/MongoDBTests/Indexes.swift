import MongoDB
import Testing

@Suite
struct Indexes:Mongo.TestBattery
{
    let collection:Mongo.Collection = "Inventory"
    let database:Mongo.Database = "Indexes"

    @Test(arguments: [.single, .replicated] as [any Mongo.TestConfiguration])
    func indexes(_ configuration:any Mongo.TestConfiguration) async throws
    {
        try await self.run(under: configuration)
    }

    func run(with pool:Mongo.SessionPool) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)

        do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 6)
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(self.collection,
                    encoding: [
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
                against: self.database)

            #expect(response == expected)
        }
        do
        {
            let expected:Mongo.CreateIndexesResponse = .init(
                createdCollectionAutomatically: false,
                indexesBefore: 1,
                indexesAfter: 3)
            let response:Mongo.CreateIndexesResponse = try await session.run(
                command: Mongo.CreateIndexes.init(self.collection,
                    writeConcern: .majority,
                    indexes: [
                        .init
                        {
                            $0[.unique] = true
                            $0[.name] = "item_manufacturer_model"
                            $0[.key, using: Product.CodingKey.self]
                            {
                                $0[.item] = (+)
                                $0[.manufacturer] = (+)
                                $0[.model] = (+)
                            }
                        },
                        .init
                        {
                            $0[.unique] = true
                            $0[.name] = "item_supplier_model"
                            $0[.key, using: Product.CodingKey.self]
                            {
                                $0[.item] = (+)
                                $0[.supplier] = (+)
                                $0[.model] = (+)
                            }
                        },
                    ]),
                against: self.database)

            #expect(response == expected)
        }
        do
        {
            let expected:Mongo.CreateIndexesResponse = .init(
                createdCollectionAutomatically: nil,
                indexesBefore: 3,
                indexesAfter: 3,
                note: "all indexes already exist")
            let response:Mongo.CreateIndexesResponse = try await session.run(
                command: Mongo.CreateIndexes.init(self.collection,
                    writeConcern: .majority,
                    indexes: [
                        .init
                        {
                            $0[.unique] = true
                            $0[.name] = "item_supplier_model"
                            $0[.key, using: Product.CodingKey.self]
                            {
                                $0[.item] = (+)
                                $0[.supplier] = (+)
                                $0[.model] = (+)
                            }
                        },
                    ]),
                against: self.database)

            #expect(response == expected)
        }
        do
        {
            let expected:Set<Mongo.IndexBinding> = [
                .init(version: 2, name: "_id_"),
                .init(version: 2, name: "item_manufacturer_model"),
                .init(version: 2, name: "item_supplier_model"),
            ]
            let returned:[Mongo.IndexBinding] = try await session.run(
                command: Mongo.ListIndexes.init(self.collection),
                against: self.database)
            {
                try await $0.reduce(into: [], +=)
            }

            #expect(Set<Mongo.IndexBinding>.init(returned) == expected)
        }

        try await session.run(
            command: Mongo.DropIndexes.init(self.collection, writeConcern: .majority)
            {
                $0[.index] = ["item_manufacturer_model", "item_supplier_model"]
            },
            against: self.database)
    }
}
