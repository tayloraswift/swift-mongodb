import BSONDecoding
import BSONEncoding
import MongoDB
import Testing

func TestDelete(_ tests:TestGroup, bootstrap:Mongo.DriverBootstrap) async
{
    guard let tests:TestGroup = tests / "delete"
    else
    {
        return
    }

    await bootstrap.withTemporaryDatabase(named: "delete-tests", tests: tests)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        let session:Mongo.Session = try await .init(from: pool)

        struct Cake:Equatable, Hashable, BSONDocumentDecodable, BSONDocumentEncodable
        {
            let location:String
            let flavor:String
            let status:String
            let points:Int

            init(location:String,
                flavor:String,
                status:String,
                points:Int)
            {
                self.location = location
                self.flavor = flavor
                self.status = status
                self.points = points
            }

            enum CodingKeys:String
            {
                case location
                case flavor
                case status
                case points
            }

            init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>)
                throws
            {
                self.init(location: try bson[.location].decode(),
                    flavor: try bson[.flavor].decode(),
                    status: try bson[.status].decode(),
                    points: try bson[.points].decode())
            }

            func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
            {
                bson[.location] = self.location
                bson[.flavor] = self.flavor
                bson[.status] = self.status
                bson[.points] = self.points
            }
        }

        let collection:Mongo.Collection = "cakes"
        let states:([Cake], [Cake], [Cake], [Cake])

        states.0 =
        [
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
        states.1 =
        [
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
        states.2 =
        [
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
        states.3 =
        [
            .init(location: "Café Barbie",
                flavor: "polypropylene",
                status: "B",
                points: 72),
        ]

        await tests.do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 7)
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(collection, encoding: states.0),
                against: database)

            tests.expect(response ==? expected)

        }
        await tests.do
        {
            let expected:Mongo.CreateIndexesResponse = .init(
                createdCollectionAutomatically: false,
                indexesBefore: 1,
                indexesAfter: 2)
            let response:Mongo.CreateIndexesResponse = try await session.run(
                command: Mongo.CreateIndexes.init(collection,
                    writeConcern: .majority,
                    indexes:
                    [
                        .init
                        {
                            $0[.name] = "points_index"
                            $0[.key] = .init
                            {
                                $0["points"] = (+)
                            }
                        },
                    ]),
                against: database)

            tests.expect(response ==? expected)
        }
        do
        {
            let tests:TestGroup = tests ! "one"

            await tests.do
            {
                let expected:Mongo.DeleteResponse = .init(deleted: 1)
                let response:Mongo.DeleteResponse = try await session.run(
                    command: Mongo.Delete<Mongo.One>.init(collection,
                        writeConcern: .majority,
                        deletes:
                        [
                            .init
                            {
                                $0[.limit] = .one
                                $0[.q] = .init
                                {
                                    $0["flavor"] = "styrene"
                                    $0["status"] = "B"
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
                let cakes:[Cake] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Cake>>.init(collection, limit: 10),
                    against: database)

                tests.expect(cakes **? states.1)
            }
        }
        do
        {
            let tests:TestGroup = tests ! "many"

            await tests.do
            {
                let expected:Mongo.DeleteResponse = .init(deleted: 2)
                let response:Mongo.DeleteResponse = try await session.run(
                    command: Mongo.Delete<Mongo.Many>.init(collection,
                        writeConcern: .majority,
                        deletes:
                        [
                            .init
                            {
                                $0[.limit] = .unlimited
                                $0[.collation] = .init(locale: "fr", strength: .primary)
                                $0[.q] = .init
                                {
                                    $0["flavor"] = "acrylic"
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
                let cakes:[Cake] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Cake>>.init(collection, limit: 10),
                    against: database)

                tests.expect(cakes **? states.2)
            }
        }
        do
        {
            let tests:TestGroup = tests ! "index-hint"

            await tests.do
            {
                let expected:Mongo.DeleteResponse = .init(deleted: 3)
                let response:Mongo.DeleteResponse = try await session.run(
                    command: Mongo.Delete<Mongo.Many>.init(collection,
                        writeConcern: .majority,
                        deletes:
                        [
                            .init
                            {
                                $0[.limit] = .unlimited
                                $0[.hint] = "points_index"
                                $0[.q] = .init
                                {
                                    $0["points"] = .init
                                    {
                                        $0[.lt] = 70
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
                let cakes:[Cake] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Cake>>.init(collection, limit: 10),
                    against: database)

                tests.expect(cakes **? states.3)
            }
        }
    }
}
