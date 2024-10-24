import MongoDB
import Testing

@Suite
struct UpdateNested:Mongo.TestBattery
{
    let collection:Mongo.Collection = "Apes"
    let database:Mongo.Database = "UpdateNested"

    //  This test is based on the tutorial from:
    //  https://www.mongodb.com/docs/manual/reference/command/update/#examples
    @Test(arguments: [.single, .replicated] as [any Mongo.TestConfiguration])
    func updateNested(_ configuration:any Mongo.TestConfiguration) async throws
    {
        try await self.run(under: configuration)
    }

    func run(with pool:Mongo.SessionPool) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)
        let states:([Ape], Set<Ape>, Set<Ape>)

        states.0 = [
            .init(id: 1,
                name: "Harambe",
                food: .init(expires: .init(index: 123), type: "Banana")),

            .init(id: 2,
                name: "George",
                food: .init(expires: .init(index: 456), type: "Watermelon")),
        ]
        states.1 = [
            .init(id: 1,
                name: "Harambe",
                food: .init(expires: .init(index: 123), type: "Banana")),

            .init(id: 2,
                name: "George",
                food: .init(expires: nil, type: "Watermelon")),
        ]
        states.2 = [
            .init(id: 1,
                name: "Harambe",
                food: .init(expires: nil, type: "Watermelon")),

            .init(id: 2,
                name: "George",
                food: .init(expires: nil, type: "Watermelon")),
        ]

        do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 2)
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(self.collection, encoding: states.0),
                against: self.database)

            #expect(response == expected)
        }
        do
        {
            let expected:Mongo.UpdateResponse<Int> = .init(selected: 1, modified: 1)
            let response:Mongo.UpdateResponse<Int> = try await session.run(
                command: Mongo.Update<Mongo.One, Int>.init(self.collection,
                    writeConcern: .majority)
                {
                    $0[.ordered] = false
                }
                    updates:
                {
                    $0
                    {
                        $0[.q] { $0[Ape[.name]] = "George" }
                        $0[.u]
                        {
                            $0[.set]
                            {
                                $0[Ape[.food]] = Ape.Food.init(expires: nil, type: "Watermelon")
                            }
                        }
                    }
                },
                against: self.database)

            #expect(response == expected)

            let apes:[Ape] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Ape>>.init(self.collection,
                    limit: 10),
                against: self.database)

            #expect(Set<Ape>.init(apes) == states.1)
        }
        do
        {
            /// This update should have no effect, because aggregation `$set` behaves
            /// differently than the update `$set`.
            let expected:Mongo.UpdateResponse<Int> = .init(selected: 1, modified: 0)
            let response:Mongo.UpdateResponse<Int> = try await session.run(
                command: Mongo.Update<Mongo.One, Int>.init(self.collection,
                    writeConcern: .majority)
                {
                    $0[.ordered] = false
                }
                    updates:
                {
                    $0
                    {
                        $0[.q] { $0[Ape[.name]] = "Harambe" }
                        $0[.u]
                        {
                            $0[stage: .set, using: Ape.CodingKey.self]
                            {
                                $0[.food] = Ape.Food.init(expires: nil, type: "Banana")
                            }
                        }
                    }
                },
                against: self.database)

            #expect(response == expected)

            let apes:[Ape] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Ape>>.init(self.collection,
                    limit: 10),
                against: self.database)

            #expect(Set<Ape>.init(apes) == states.1)
        }
        do
        {
            let expected:Mongo.UpdateResponse<Int> = .init(selected: 1, modified: 1)
            let response:Mongo.UpdateResponse<Int> = try await session.run(
                command: Mongo.Update<Mongo.One, Int>.init(self.collection,
                    writeConcern: .majority)
                {
                    $0[.ordered] = false
                }
                    updates:
                {
                    $0
                    {
                        $0[.q] { $0["name"] = "Harambe" }
                        $0[.u]
                        {
                            $0[stage: .set, using: Ape.CodingKey.self]
                            {
                                $0[.food]
                                {
                                    $0[.literal] = Ape.Food.init(
                                        expires: nil,
                                        type: "Watermelon")
                                }
                            }
                        }
                    }
                },
                against: self.database)

            #expect(response == expected)

            let apes:[Ape] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Ape>>.init(self.collection,
                    limit: 10),
                against: self.database)

            #expect(Set<Ape>.init(apes) == states.2)
        }
    }
}
