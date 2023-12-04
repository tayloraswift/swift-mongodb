import MongoDB
import MongoTesting

struct Update:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)

        //  This test is based on the tutorial from:
        //  https://www.mongodb.com/docs/manual/reference/command/update/#examples

        let collection:Mongo.Collection = "members"
        let states:([Member], [Member], [Member], [Member], [Member])

        states.0 =
        [
            .init(id: 1,
                member: "abc123",
                status: "Pending",
                points: 0,
                misc1: "note to self: confirm status",
                misc2: "Need to activate"),

            .init(id: 2,
                member: "xyz123",
                status: "D",
                points: 59,
                misc1: "reminder: ping me at 100pts",
                misc2: "Some random comment"),
        ]
        states.1 =
        [
            .init(id: 1,
                member: "abc123",
                status: "A",
                points: 1,
                misc1: "note to self: confirm status",
                misc2: "Need to activate"),

            .init(id: 2,
                member: "xyz123",
                status: "D",
                points: 59,
                misc1: "reminder: ping me at 100pts",
                misc2: "Some random comment"),
        ]
        states.2 =
        [
            .init(id: 1,
                member: "abc123",
                status: "A",
                points: 2,
                misc1: "note to self: confirm status",
                misc2: "Need to activate"),

            .init(id: 2,
                member: "xyz123",
                status: "A",
                points: 60,
                misc1: "reminder: ping me at 100pts",
                misc2: "Some random comment"),
        ]
        states.3 =
        [
            .init(id: 1,
                member: "abc123",
                status: "Modified",
                points: 2,
                comments: ["note to self: confirm status", "Need to activate"]),

            .init(id: 2,
                member: "xyz123",
                status: "Modified",
                points: 60,
                comments: ["reminder: ping me at 100pts", "Some random comment"]),
        ]
        states.4 =
        [
            .init(id: 1,
                member: "abc123",
                status: "Modified",
                points: 2,
                comments: ["note to self: confirm status", "Need to activate"]),

            .init(id: 2,
                member: "xyz123",
                status: "Modified",
                points: 60,
                comments: ["reminder: ping me at 100pts", "Some random comment"]),

            .init(id: 3,
                member: "upserted",
                status: "A",
                points: 0),
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
            let tests:TestGroup = tests ! "one"

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
                            $0[.q] = .init
                            {
                                $0["member"] = "abc123"
                            }
                            $0[.u] = .init
                            {
                                $0[.set] = .init
                                {
                                    $0["status"] = "A"
                                }
                                $0[.inc] = .init
                                {
                                    $0["points"] = 1
                                }
                            }
                        }
                    },
                    against: database)

                tests.expect(response ==? expected)
            }
            await tests.do
            {
                let members:[Member] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Member>>.init(collection,
                        limit: 10),
                    against: database)

                tests.expect(members **? states.1)
            }
        }
        do
        {
            let tests:TestGroup = tests ! "many"

            await tests.do
            {
                let expected:Mongo.UpdateResponse<Int> = .init(selected: 2, modified: 2)
                let response:Mongo.UpdateResponse<Int> = try await session.run(
                    command: Mongo.Update<Mongo.Many, Int>.init(collection,
                        writeConcern: .majority)
                    {
                        $0[.ordered] = false
                    }
                        updates:
                    {
                        $0
                        {
                            $0[.q] = .init()
                            $0[.u] = .init
                            {
                                $0[.set] = .init
                                {
                                    $0["status"] = "A"
                                }
                                $0[.inc] = .init
                                {
                                    $0["points"] = 1
                                }
                            }
                            $0[.multi] = true
                        }
                    },
                    against: database)

                tests.expect(response ==? expected)
            }
            await tests.do
            {
                let members:[Member] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Member>>.init(collection,
                        limit: 10),
                    against: database)

                tests.expect(members **? states.2)
            }
        }
        do
        {
            let tests:TestGroup = tests ! "pipeline"

            await tests.do
            {
                let expected:Mongo.UpdateResponse<Int> = .init(selected: 2, modified: 2)
                let response:Mongo.UpdateResponse<Int> = try await session.run(
                    command: Mongo.Update<Mongo.Many, Int>.init(collection,
                        writeConcern: .majority)
                    {
                        $0[.ordered] = false
                    }
                        updates:
                    {
                        $0
                        {
                            $0[.q] = .init()
                            $0[.u] = .init
                            {
                                $0.stage
                                {
                                    $0[.set] = .init
                                    {
                                        $0["status"] = "Modified"
                                        $0["comments"] = ["$misc1", "$misc2"]
                                    }
                                }
                                $0.stage
                                {
                                    $0[.unset] = ["misc1", "misc2"]
                                }
                            }
                            $0[.multi] = true
                        }
                    },
                    against: database)

                tests.expect(response ==? expected)
            }
            await tests.do
            {
                let members:[Member] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Member>>.init(collection,
                        limit: 10),
                    against: database)

                tests.expect(members **? states.3)
            }
        }
        do
        {
            let tests:TestGroup = tests ! "upsert"

            await tests.do
            {
                let expected:Mongo.UpdateResponse<Int> = .init(selected: 1,
                    modified: 0,
                    upserted: [.init(index: 0, id: 3)])
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
                            $0[.q] = .init
                            {
                                $0["_id"] = 3
                            }
                            $0[.u] = states.4.last
                            $0[.upsert] = true
                        }
                    },
                    against: database)

                tests.expect(response ==? expected)
            }
            await tests.do
            {
                let members:[Member] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Member>>.init(collection,
                        limit: 10),
                    against: database)

                tests.expect(members **? states.4)
            }
        }
    }
}
