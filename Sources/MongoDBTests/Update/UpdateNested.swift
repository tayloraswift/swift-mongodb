import MongoDB
import MongoTesting

struct UpdateNested<Configuration>:MongoTestBattery where Configuration:MongoTestConfiguration
{
    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)

        //  This test is based on the tutorial from:
        //  https://www.mongodb.com/docs/manual/reference/command/update/#examples

        let collection:Mongo.Collection = "apes"
        let states:([Ape], [Ape], [Ape])

        states.0 =
        [
            .init(id: 1,
                name: "Harambe",
                food: .init(expires: .init(index: 123), type: "Banana")),

            .init(id: 2,
                name: "George",
                food: .init(expires: .init(index: 456), type: "Watermelon")),
        ]

        states.1 =
        [
            .init(id: 1,
                name: "Harambe",
                food: .init(expires: .init(index: 123), type: "Banana")),

            .init(id: 2,
                name: "George",
                food: .init(expires: nil, type: "Watermelon")),
        ]

        states.2 =
        [
            .init(id: 1,
                name: "Harambe",
                food: .init(expires: nil, type: "Watermelon")),

            .init(id: 2,
                name: "George",
                food: .init(expires: nil, type: "Watermelon")),
        ]

        await tests.do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 2)
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(collection, encoding: states.0),
                against: database)

            tests.expect(response ==? expected)
        }

        do
        {
            let tests:TestGroup = tests ! "SetField"

            await tests.do
            {
                let expected:Mongo.UpdateResponse<Int> = .init(selected: 1, modified: 1)
                let response:Mongo.UpdateResponse<Int> = try await session.run(
                    command: Mongo.Update<Mongo.One, Int>.init(collection,
                        writeConcern: .majority)
                    {
                        $0[.ordered] = false
                    }
                        updates:
                    {
                        $0
                        {
                            $0[.q]
                            {
                                $0["name"] = "George"
                            }
                            $0[.u]
                            {
                                $0[.set]
                                {
                                    $0["food"] = Ape.Food.init(expires: nil, type: "Watermelon")
                                }
                            }
                        }
                    },
                    against: database)

                tests.expect(response ==? expected)
            }
            await tests.do
            {
                let apes:[Ape] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Ape>>.init(collection,
                        limit: 10),
                    against: database)

                tests.expect(apes **? states.1)
            }
        }
        do
        {
            let tests:TestGroup = tests ! "SetFieldWithPipeline"

            await tests.do
            {
                /// This update should have no effect, because aggregation `$set` behaves
                /// differently than the update `$set`.
                let expected:Mongo.UpdateResponse<Int> = .init(selected: 1, modified: 0)
                let response:Mongo.UpdateResponse<Int> = try await session.run(
                    command: Mongo.Update<Mongo.One, Int>.init(collection,
                        writeConcern: .majority)
                    {
                        $0[.ordered] = false
                    }
                        updates:
                    {
                        $0
                        {
                            $0[.q]
                            {
                                $0[Ape[.name]] = "Harambe"
                            }
                            $0[.u]
                            {
                                $0[stage: .set, using: Ape.CodingKey.self]
                                {
                                    $0[.food] = Ape.Food.init(expires: nil, type: "Banana")
                                }
                            }
                        }
                    },
                    against: database)

                tests.expect(response ==? expected)
            }
            await tests.do
            {
                let apes:[Ape] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Ape>>.init(collection,
                        limit: 10),
                    against: database)

                tests.expect(apes **? states.1)
            }
        }
        do
        {
            let tests:TestGroup = tests ! "ReplaceFieldWithPipeline"

            await tests.do
            {
                let expected:Mongo.UpdateResponse<Int> = .init(selected: 1, modified: 1)
                let response:Mongo.UpdateResponse<Int> = try await session.run(
                    command: Mongo.Update<Mongo.One, Int>.init(collection,
                        writeConcern: .majority)
                    {
                        $0[.ordered] = false
                    }
                        updates:
                    {
                        $0
                        {
                            $0[.q]
                            {
                                $0["name"] = "Harambe"
                            }
                            $0[.u]
                            {
                                $0[stage: .set, using: Ape.CodingKey.self]
                                {
                                    $0[.food]
                                    {
                                        $0[.literal] = Ape.Food.init(expires: nil,
                                            type: "Watermelon")
                                    }
                                }
                            }
                        }
                    },
                    against: database)

                tests.expect(response ==? expected)
            }
            await tests.do
            {
                let apes:[Ape] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Ape>>.init(collection,
                        limit: 10),
                    against: database)

                tests.expect(apes **? states.2)
            }
        }
    }
}
