import BSONDecoding
import BSONEncoding
import MongoDB
import Testing

func TestAggregate(_ tests:TestGroup, bootstrap:Mongo.DriverBootstrap) async
{
    guard let tests:TestGroup = tests / "aggregate"
    else
    {
        return
    }

    await bootstrap.withTemporaryDatabase(named: "aggregate-tests", tests: tests)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        let session:Mongo.Session = try await .init(from: pool)

        if  let tests:TestGroup = tests / "articles-example"
        {
            let collection:Mongo.Collection = "articles"

            struct Article:Equatable, Hashable, BSONDocumentDecodable, BSONDocumentEncodable
            {
                let id:BSON.Identifier
                let author:String
                let title:String
                let views:Int
                let tags:[String]

                init(id:BSON.Identifier,
                    author:String,
                    title:String,
                    views:Int,
                    tags:[String])
                {
                    self.id = id
                    self.author = author
                    self.title = title
                    self.views = views
                    self.tags = tags
                }

                enum CodingKeys:String
                {
                    case id = "_id"
                    case author
                    case title
                    case views
                    case tags
                }

                init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>)
                    throws
                {
                    self.init(id: try bson[.id].decode(),
                        author: try bson[.author].decode(),
                        title: try bson[.title].decode(),
                        views: try bson[.views].decode(),
                        tags: try bson[.tags].decode())
                }

                func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
                {
                    bson[.id] = self.id
                    bson[.author] = self.author
                    bson[.title] = self.title
                    bson[.views] = self.views
                    bson[.tags] = self.tags
                }
            }
            await tests.do
            {
                let expected:Mongo.InsertResponse = .init(inserted: 4)
                let response:Mongo.InsertResponse = try await session.run(
                    command: Mongo.Insert.init(collection: collection, elements:
                    [
                        .init(id: 0x5276_9ea0_f3dc_6ead_47c9_a1b2,
                            author: "barbie",
                            title: "Brain Surgery for Beginners",
                            views: 527,
                            tags: ["medicine", "neuroscience", "education"]),

                        .init(id: 0x5276_9ea0_f3dc_6ead_47c9_a1b3,
                            author: "barbie",
                            title: "NATO Expansion and Unipolar Norms: A Review",
                            views: 760,
                            tags: ["politics", "history"]),

                        .init(id: 0x5276_9ea0_f3dc_6ead_47c9_a1b4,
                            author: "raquelle",
                            title: "A Brief History of Raquelle (Vol. 1)",
                            views: 288,
                            tags: ["history", "autobiography"]),

                        .init(id: 0x5276_9ea0_f3dc_6ead_47c9_a1b5,
                            author: "raquelle",
                            title: "A Brief History of Raquelle (Vol. 2)",
                            views: 115,
                            tags: ["history", "autobiography"]),
                    ] as [Article]),
                    against: database)

                tests.expect(response ==? expected)
            }

            struct TagStats:Equatable, Hashable, BSONDocumentDecodable
            {
                let id:String
                let count:Int

                init(id:String, count:Int)
                {
                    self.id = id
                    self.count = count
                }

                enum CodingKeys:String
                {
                    case id = "_id"
                    case count
                }

                init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>)
                    throws
                {
                    self.init(id: try bson[.id].decode(), count: try bson[.count].decode())
                }
            }
            await tests.do
            {
                let expected:[TagStats] =
                [
                    .init(id: "medicine", count: 1),
                    .init(id: "neuroscience", count: 1),
                    .init(id: "education", count: 1),
                    .init(id: "history", count: 3),
                    .init(id: "politics", count: 1),
                    .init(id: "autobiography", count: 2),
                ]
                let response:[TagStats] = try await session.run(
                    command: Mongo.Aggregate<Mongo.Cursor<TagStats>>.init(
                        collection: collection,
                        writeConcern: .majority,
                        readConcern: .majority,
                        pipeline: .init
                        {
                            $0.stage
                            {
                                $0[.project] = .init { $0["tags"] = 1 }
                            }
                            $0.stage
                            {
                                $0[.unwind] = "$tags"
                            }
                            $0.stage
                            {
                                $0[.group] = .init
                                {
                                    $0[.id] = "$tags"

                                    $0["count"] = .init { $0[.sum] = 1 }
                                }
                            }
                        },
                        stride: 10),
                    against: database)
                {
                    try await $0.reduce(into: []) { $0 += $1 }
                }

                tests.expect(response **? expected)
            }

            struct AuthorStats:Equatable, Hashable, BSONDocumentDecodable
            {
                let id:String
                let views:Int

                init(id:String, views:Int)
                {
                    self.id = id
                    self.views = views
                }

                enum CodingKeys:String
                {
                    case id = "_id"
                    case views
                }

                init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>)
                    throws
                {
                    self.init(id: try bson[.id].decode(), views: try bson[.views].decode())
                }
            }
            await tests.do
            {
                let expected:[AuthorStats] =
                [
                    .init(id: "barbie", views: 527 + 760),
                    .init(id: "raquelle", views: 288 + 115),
                ]
                let response:[AuthorStats] = try await session.run(
                    command: Mongo.Aggregate<Mongo.Cursor<AuthorStats>>.init(
                        collection: collection,
                        writeConcern: .majority,
                        readConcern: .majority,
                        pipeline: .init
                        {
                            $0.stage
                            {
                                $0[.project] = .init
                                {
                                    $0["author"] = 1
                                    $0["views"] = 1
                                }
                            }
                            $0.stage
                            {
                                $0[.group] = .init
                                {
                                    $0[.id] = "$author"

                                    $0["views"] = .init { $0[.sum] = "$views" }
                                }
                            }
                        },
                        stride: 10),
                    against: database)
                {
                    try await $0.reduce(into: []) { $0 += $1 }
                }

                tests.expect(response **? expected)
            }
        }
    }
}
