import BSONDecoding
import BSONEncoding
import MongoDB
import Testing

func TestUpdate(_ tests:TestGroup, bootstrap:Mongo.DriverBootstrap) async
{
    guard let tests:TestGroup = tests / "update"
    else
    {
        return
    }

    await bootstrap.withTemporaryDatabase(named: "update-tests", tests: tests)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        let session:Mongo.Session = try await .init(from: pool)

        //  This test is based on the tutorial from:
        //  https://www.mongodb.com/docs/manual/reference/command/update/#examples
        if  let tests:TestGroup = tests / "members-example"
        {
            struct Member:Equatable, Hashable, BSONDocumentDecodable, BSONDocumentEncodable
            {
                let id:Int
                let member:String
                let status:String
                let points:Int
                let comments:[String]
                let misc1:String?
                let misc2:String?

                init(id:Int,
                    member:String,
                    status:String,
                    points:Int,
                    comments:[String] = [],
                    misc1:String? = nil,
                    misc2:String? = nil)
                {
                    self.id = id
                    self.member = member
                    self.status = status
                    self.points = points
                    self.comments = comments
                    self.misc1 = misc1
                    self.misc2 = misc2
                }

                enum CodingKeys:String
                {
                    case id = "_id"
                    case member
                    case status
                    case points
                    case comments
                    case misc1
                    case misc2
                }

                init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>)
                    throws
                {
                    self.init(id: try bson[.id].decode(),
                        member: try bson[.member].decode(),
                        status: try bson[.status].decode(),
                        points: try bson[.points].decode(),
                        comments: try bson[.comments]?.decode() ?? [],
                        misc1: try bson[.misc1]?.decode(),
                        misc2: try bson[.misc2]?.decode())
                }

                func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
                {
                    bson[.id] = self.id
                    bson[.member] = self.member
                    bson[.status] = self.status
                    bson[.points] = self.points
                    bson[.comments] = self.comments.isEmpty ? nil : self.comments
                    bson[.misc1] = self.misc1
                    bson[.misc2] = self.misc2
                }
            }

            let collection:Mongo.Collection = "members"
            let states:([Member], [Member], [Member], [Member])

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
                let tests:TestGroup = tests ! "update-one"

                await tests.do
                {
                    let expected:Mongo.UpdateResponse<Int> = .init(selected: 1, modified: 1)
                    let response:Mongo.UpdateResponse<Int> = try await session.run(
                        command: Mongo.Update<Mongo.One, Int>.init(collection,
                            writeConcern: .majority,
                            updates:
                            [
                                .init
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
                                },
                            ])
                            {
                                $0[.ordered] = false
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
                let tests:TestGroup = tests ! "update-many"

                await tests.do
                {
                    let expected:Mongo.UpdateResponse<Int> = .init(selected: 2, modified: 2)
                    let response:Mongo.UpdateResponse<Int> = try await session.run(
                        command: Mongo.Update<Mongo.Many, Int>.init(collection,
                            writeConcern: .majority,
                            updates:
                            [
                                .init
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
                                },
                            ])
                            {
                                $0[.ordered] = false
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
                let tests:TestGroup = tests ! "update-pipeline"

                await tests.do
                {
                    let expected:Mongo.UpdateResponse<Int> = .init(selected: 2, modified: 2)
                    let response:Mongo.UpdateResponse<Int> = try await session.run(
                        command: Mongo.Update<Mongo.Many, Int>.init(collection,
                            writeConcern: .majority,
                            updates:
                            [
                                .init
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
                                },
                            ])
                            {
                                $0[.ordered] = false
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
        }
    }
}
