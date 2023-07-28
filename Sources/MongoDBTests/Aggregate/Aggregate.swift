import MongoDB
import MongoTesting

struct Aggregate:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)

        if  let tests:TestGroup = tests / "articles-example"
        {
            let collection:Mongo.Collection = "articles"

            await tests.do
            {
                let expected:Mongo.InsertResponse = .init(inserted: 4)
                let response:Mongo.InsertResponse = try await session.run(
                    command: Mongo.Insert.init(collection, encoding: [
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
                    command: Mongo.Aggregate<Mongo.Cursor<TagStats>>.init(collection,
                        writeConcern: .majority,
                        readConcern: .majority,
                        pipeline: .init
                        {
                            $0.stage
                            {
                                $0[.project] = .init { $0[Article[.tags]] = 1 }
                            }
                            $0.stage
                            {
                                $0[.unwind] = Article[.tags]
                            }
                            $0.stage
                            {
                                $0[.group] = .init
                                {
                                    $0[.id] = Article[.tags]

                                    $0[TagStats[.count]] = .init { $0[.sum] = 1 }
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

            await tests.do
            {
                let expected:[AuthorStats] =
                [
                    .init(id: "barbie", views: 527 + 760),
                    .init(id: "raquelle", views: 288 + 115),
                ]
                let response:[AuthorStats] = try await session.run(
                    command: Mongo.Aggregate<Mongo.Cursor<AuthorStats>>.init(collection,
                        writeConcern: .majority,
                        readConcern: .majority,
                        pipeline: .init
                        {
                            $0.stage
                            {
                                $0[.project] = .init
                                {
                                    $0[Article[.author]] = 1
                                    $0[Article[.views]] = 1
                                }
                            }
                            $0.stage
                            {
                                $0[.group] = .init
                                {
                                    $0[.id] = Article[.author]

                                    $0[Article[.views]] = .init { $0[.sum] = Article[.views] }
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
