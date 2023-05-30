import BSONDecoding
import BSONEncoding
import MongoDB
import Testing

func TestFindAndModify(_ tests:TestGroup, bootstrap:Mongo.DriverBootstrap) async
{
    guard let tests:TestGroup = tests / "find-and-modify"
    else
    {
        return
    }

    await bootstrap.withTemporaryDatabase(named: "find-and-modify-tests", tests: tests)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        let session:Mongo.Session = try await .init(from: pool)

        struct Ruler:Equatable, Hashable, BSONDocumentDecodable, BSONDocumentEncodable
        {
            let id:String
            let party:String
            let since:Int

            init(id:String,
                party:String,
                since:Int)
            {
                self.id = id
                self.party = party
                self.since = since
            }

            enum CodingKeys:String
            {
                case id = "_id"
                case party
                case since
            }

            init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>)
                throws
            {
                self.init(id: try bson[.id].decode(),
                    party: try bson[.party].decode(),
                    since: try bson[.since].decode())
            }

            func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
            {
                bson[.id] = self.id
                bson[.party] = self.party
                bson[.since] = self.since
            }
        }

        let rulers:Mongo.Collection = "rulers"
        let states:([Ruler], [Ruler], [Ruler], [Ruler])

        states.0 =
        [
            .init(id: "Giorgia Meloni",
                party: "Fratelli d’Italia",
                since: 2022),

            .init(id: "Jeanine Áñez Chávez",
                party: "Demócratas",
                since: 2019),

            .init(id: "Dina Ercilia Boluarte Zegarra",
                party: "Perú Libre",
                since: 2022),

            .init(id: "Mary Elizabeth Truss",
                party: "Conservatives",
                since: 2022),
        ]
        states.1 =
        [
            .init(id: "Giorgia Meloni",
                party: "Fratelli d’Italia",
                since: 2022),

            .init(id: "Jeanine Áñez Chávez",
                party: "Demócratas",
                since: 2019),

            .init(id: "Dina Ercilia Boluarte Zegarra",
                party: "Independent",
                since: 2022),

            .init(id: "Mary Elizabeth Truss",
                party: "Conservatives",
                since: 2022),
        ]
        states.2 =
        [
            .init(id: "Giorgia Meloni",
                party: "Fratelli d’Italia",
                since: 2022),

            .init(id: "Jeanine Áñez Chávez",
                party: "Demócratas",
                since: 2019),

            .init(id: "Dina Ercilia Boluarte Zegarra",
                party: "Independent",
                since: 2022),

            .init(id: "Mary Elizabeth Truss",
                party: "Conservatives",
                since: 2022),

            .init(id: "Marion Anne Perrine Le Pen",
                party: "Rassemblement National",
                since: 2027)
        ]
        states.3 =
        [
            .init(id: "Giorgia Meloni",
                party: "Fratelli d’Italia",
                since: 2022),

            .init(id: "Dina Ercilia Boluarte Zegarra",
                party: "Independent",
                since: 2022),

            .init(id: "Mary Elizabeth Truss",
                party: "Conservatives",
                since: 2022),

            .init(id: "Marion Anne Perrine Le Pen",
                party: "Rassemblement National",
                since: 2027)
        ]

        await tests.do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 4)
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(rulers, encoding: states.0),
                against: database)

            tests.expect(response ==? expected)
        }
        do
        {
            let tests:TestGroup = tests ! "existing"

            await tests.do
            {
                let expected:Ruler = .init(id: "Dina Ercilia Boluarte Zegarra",
                    party: "Independent",
                    since: 2022)
                let (response, _):(Ruler?, Never?) = try await session.run(
                    command: Mongo.FindAndModify<Mongo.Existing<Ruler>>.init(rulers,
                        writeConcern: .majority,
                        returning: .new)
                        {
                            $0[.query] = .init
                            {
                                $0["_id"] = "Dina Ercilia Boluarte Zegarra"
                            }
                            $0[.update] = .init
                            {
                                $0[.set] = .init
                                {
                                    $0["party"] = "Independent"
                                }
                            }
                        },
                    against: database)

                tests.expect(response ==? expected)
            }
            await tests.do
            {
                let rulers:[Ruler] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Ruler>>.init(rulers,
                        limit: 10),
                    against: database)

                tests.expect(rulers **? states.1)
            }
        }
        do
        {
            let tests:TestGroup = tests ! "upserting"

            await tests.do
            {
                let expected:Ruler = .init(id: "Marion Anne Perrine Le Pen",
                    party: "Rassemblement National",
                    since: 2027)
                let (response, upserted):(Ruler?, String?) = try await session.run(
                    command: Mongo.FindAndModify<Mongo.Upserting<Ruler, String>>.init(rulers,
                        writeConcern: .majority,
                        returning: .new)
                        {
                            $0[.query] = .init
                            {
                                $0["_id"] = expected.id
                            }
                            $0[.update] = expected
                        },
                    against: database)

                tests.expect(response ==? expected)
                tests.expect(upserted ==? expected.id)
            }
            await tests.do
            {
                let rulers:[Ruler] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Ruler>>.init(rulers,
                        limit: 10),
                    against: database)

                tests.expect(rulers **? states.2)
            }
        }
        do
        {
            let tests:TestGroup = tests ! "removing"

            await tests.do
            {
                let expected:Ruler = .init(id: "Jeanine Áñez Chávez",
                    party: "Demócratas",
                    since: 2019)
                let (response, _):(Ruler?, Never?) = try await session.run(
                    command: Mongo.FindAndModify<Mongo.Removing<Ruler>>.init(rulers,
                        writeConcern: .majority,
                        returning: .deleted)
                        {
                            $0[.sort] = .init
                            {
                                $0["since"] = (+)
                            }
                        },
                    against: database)

                tests.expect(response ==? expected)
            }
            await tests.do
            {
                let rulers:[Ruler] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Ruler>>.init(rulers,
                        limit: 10),
                    against: database)

                tests.expect(rulers **? states.3)
            }
        }
    }
}
