import MongoDB
import Testing

@Suite
struct Delete:Mongo.TestBattery
{
    let collection:Mongo.Collection = "Cakes"
    let database:Mongo.Database = "Delete"

    @Test(arguments: [.single, .replicated] as [any Mongo.TestConfiguration])
    func delete(_ configuration:any Mongo.TestConfiguration) async throws
    {
        try await self.run(under: configuration)
    }

    func run(with pool:Mongo.SessionPool) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)

        let states:([Cake], Set<Cake>, Set<Cake>, Set<Cake>)

        states.0 = [
            .init(location: "Café Barbie",
                flavor: "styrene",
                status: "A",
                points: 2),

            .init(location: "Cafe Barbie",
                flavor: "styrene",
                status: "B",
                points: 15),

            .init(location: "Café Barbie",
                flavor: "acrylic",
                status: "A",
                points: 10),

            .init(location: "CafE Barbie",
                flavor: "acrylic",
                status: "A",
                points: 1),

            .init(location: "Café Barbie",
                flavor: "nylon",
                status: "B",
                points: 3),

            .init(location: "Café Barbie",
                flavor: "polypropylene",
                status: "B",
                points: 72),

            .init(location: "Café Barbie",
                flavor: "polypropylene",
                status: "C",
                points: 50),
        ]
        states.1 = [
            .init(location: "Café Barbie",
                flavor: "styrene",
                status: "A",
                points: 2),

            .init(location: "Café Barbie",
                flavor: "acrylic",
                status: "A",
                points: 10),

            .init(location: "CafE Barbie",
                flavor: "acrylic",
                status: "A",
                points: 1),

            .init(location: "Café Barbie",
                flavor: "nylon",
                status: "B",
                points: 3),

            .init(location: "Café Barbie",
                flavor: "polypropylene",
                status: "B",
                points: 72),

            .init(location: "Café Barbie",
                flavor: "polypropylene",
                status: "C",
                points: 50),
        ]
        states.2 = [
            .init(location: "Café Barbie",
                flavor: "styrene",
                status: "A",
                points: 2),

            .init(location: "Café Barbie",
                flavor: "nylon",
                status: "B",
                points: 3),

            .init(location: "Café Barbie",
                flavor: "polypropylene",
                status: "B",
                points: 72),

            .init(location: "Café Barbie",
                flavor: "polypropylene",
                status: "C",
                points: 50),
        ]
        states.3 = [
            .init(location: "Café Barbie",
                flavor: "polypropylene",
                status: "B",
                points: 72),
        ]

        do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 7)
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(self.collection, encoding: states.0),
                against: self.database)

            #expect(response == expected)
        }
        do
        {
            let expected:Mongo.CreateIndexesResponse = .init(
                createdCollectionAutomatically: false,
                indexesBefore: 1,
                indexesAfter: 2)
            let response:Mongo.CreateIndexesResponse = try await session.run(
                command: Mongo.CreateIndexes.init(self.collection,
                    writeConcern: .majority,
                    indexes:
                    [
                        .init
                        {
                            $0[.name] = "points_index"
                            $0[.key, using: Cake.CodingKey.self]
                            {
                                $0[.points] = (+)
                            }
                        },
                    ]),
                against: self.database)

            #expect(response == expected)
        }
        do
        {
            let expected:Mongo.DeleteResponse = .init(deleted: 1)
            let response:Mongo.DeleteResponse = try await session.run(
                command: Mongo.Delete<Mongo.One>.init(self.collection,
                    writeConcern: .majority)
                {
                    $0[.ordered] = false
                }
                    deletes:
                {
                    $0
                    {
                        $0[.limit] = .one
                        $0[.q]
                        {
                            $0["flavor"] = "styrene"
                            $0["status"] = "B"
                        }
                    }
                },
                against: self.database)

            #expect(response == expected)

            let cakes:[Cake] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Cake>>.init(self.collection, limit: 10),
                against: self.database)

            #expect(Set<Cake>.init(cakes) == states.1)
        }
        do
        {
            let expected:Mongo.DeleteResponse = .init(deleted: 2)
            let response:Mongo.DeleteResponse = try await session.run(
                command: Mongo.Delete<Mongo.Many>.init(self.collection,
                    writeConcern: .majority)
                {
                    $0[.ordered] = false
                }
                    deletes:
                {
                    $0
                    {
                        $0[.limit] = .unlimited
                        $0[.collation] = .init(locale: "fr", strength: .primary)
                        $0[.q]
                        {
                            $0["flavor"] = "acrylic"
                        }
                    }
                },
                against: self.database)

            #expect(response == expected)

            let cakes:[Cake] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Cake>>.init(self.collection, limit: 10),
                against: self.database)

            #expect(Set<Cake>.init(cakes) == states.2)
        }
        do
        {
            let expected:Mongo.DeleteResponse = .init(deleted: 3)
            let response:Mongo.DeleteResponse = try await session.run(
                command: Mongo.Delete<Mongo.Many>.init(self.collection,
                    writeConcern: .majority)
                {
                    $0[.ordered] = false
                }
                    deletes:
                {
                    $0
                    {
                        $0[.limit] = .unlimited
                        $0[.hint] = "points_index"
                        $0[.q]
                        {
                            $0["points"]
                            {
                                $0[.lt] = 70
                            }
                        }
                    }
                },
                against: self.database)

            #expect(response == expected)

            let cakes:[Cake] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Cake>>.init(self.collection, limit: 10),
                against: self.database)

            #expect(Set<Cake>.init(cakes) == states.3)
        }
    }
}
