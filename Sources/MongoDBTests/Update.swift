import MongoDB
import Testing

@Suite
struct Update:Mongo.TestBattery
{
    let collection:Mongo.Collection = "Members"
    let database:Mongo.Database = "Update"

    //  This test is based on the tutorial from:
    //  https://www.mongodb.com/docs/manual/reference/command/update/#examples
    @Test(arguments: [.single, .replicated] as [any Mongo.TestConfiguration])
    func update(_ configuration:any Mongo.TestConfiguration) async throws
    {
        try await self.run(under: configuration)
    }

    func run(with pool:Mongo.SessionPool) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)
        let states:([Member], Set<Member>, [Member], Set<Member>, Set<Member>, [Member])

        states.0 = [
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
        states.1 = [
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
        states.2 = [
            .init(id: 1,
                member: "abc123",
                status: "A",
                points: 1,
                misc1: "note to self: confirm status",
                misc2: "Need to activate"),

            .init(id: 2,
                member: "xyz123",
                status: "A",
                points: 59,
                misc1: "reminder: ping me at 100pts",
                misc2: nil),
        ]
        states.3 = [
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
                misc2: nil),
        ]
        states.4 = [
            .init(id: 1,
                member: "abc123",
                status: "Modified",
                points: 2,
                comments: ["note to self: confirm status", "Need to activate"]),

            .init(id: 2,
                member: "xyz123",
                status: "Modified",
                points: 60,
                comments: ["reminder: ping me at 100pts", nil]),
        ]
        states.5 = [
            .init(id: 1,
                member: "abc123",
                status: "Modified",
                points: 2,
                comments: ["note to self: confirm status", "Need to activate"]),

            .init(id: 2,
                member: "xyz123",
                status: "Modified",
                points: 60,
                comments: ["reminder: ping me at 100pts", nil]),

            .init(id: 3,
                member: "upserted",
                status: "A",
                points: 0),
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
                        $0[.q] { $0["member"] = "abc123" }
                        $0[.u]
                        {
                            $0[.set] { $0["status"] = "A" }
                            $0[.inc] { $0["points"] = 1 }
                        }
                    }
                },
                against: self.database)

            #expect(response == expected)

            let members:[Member] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Member>>.init(self.collection,
                    limit: 10),
                against: self.database)

            #expect(Set<Member>.init(members) == states.1)
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
                        $0[.q] { $0["_id"] = states.2.last?.id }
                        $0[.u] = states.2.last
                    }
                },
                against: self.database)

            #expect(response == expected)

            let members:[Member] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Member>>.init(self.collection,
                    limit: 10),
                against: self.database)

            #expect(Set<Member>.init(members) == Set<Member>.init(states.2))
        }
        do
        {
            let expected:Mongo.UpdateResponse<Int> = .init(selected: 2, modified: 2)
            let response:Mongo.UpdateResponse<Int> = try await session.run(
                command: Mongo.Update<Mongo.Many, Int>.init(self.collection,
                    writeConcern: .majority)
                {
                    $0[.ordered] = false
                }
                    updates:
                {
                    $0
                    {
                        $0[.q] = [:]
                        $0[.u]
                        {
                            $0[.set] { $0["status"] = "A" }
                            $0[.inc] { $0["points"] = 1 }
                        }
                        $0[.multi] = true
                    }
                },
                against: self.database)

            #expect(response == expected)

            let members:[Member] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Member>>.init(self.collection,
                    limit: 10),
                against: self.database)

            #expect(Set<Member>.init(members) == states.3)
        }
        do
        {
            let expected:Mongo.UpdateResponse<Int> = .init(selected: 2, modified: 2)
            let response:Mongo.UpdateResponse<Int> = try await session.run(
                command: Mongo.Update<Mongo.Many, Int>.init(self.collection,
                    writeConcern: .majority)
                {
                    $0[.ordered] = false
                }
                    updates:
                {
                    $0
                    {
                        $0[.q] = [:]
                        $0[.u]
                        {
                            $0[stage: .set, using: Member.CodingKey.self]
                            {
                                $0[.status] = "Modified"
                                $0[.comments] = ["$misc1", "$misc2"]
                            }
                            $0[stage: .unset] = ["misc1", "misc2"]
                        }
                        $0[.multi] = true
                    }
                },
                against: self.database)

            #expect(response == expected)

            let members:[Member] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Member>>.init(self.collection,
                    limit: 10),
                against: self.database)

            #expect(Set<Member>.init(members) == states.4)
        }
        do
        {
            let expected:Mongo.UpdateResponse<Int> = .init(selected: 1,
                modified: 0,
                upserted: [.init(index: 0, id: 3)])
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
                        $0[.q] { $0["_id"] = 3 }
                        $0[.u] = states.5.last
                        $0[.upsert] = true
                    }
                },
                against: self.database)

            #expect(response == expected)

            let members:[Member] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Member>>.init(self.collection,
                    limit: 10),
                against: self.database)

            #expect(Set<Member>.init(members) == Set<Member>.init(states.5))
        }
    }
}
