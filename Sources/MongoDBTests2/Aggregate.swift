@_spi(session) import MongoDB
import Testing

@Suite
struct Aggregate:Mongo.TestBattery
{
    let collection:Mongo.Collection = "Articles"
    let database:Mongo.Database = "Aggregate"

    //  This test is based on the tutorial from:
    //  https://www.mongodb.com/docs/manual/reference/command/update/#examples
    @Test(arguments: [.single, .replicated] as [any Mongo.TestConfiguration])
    func aggregate(_ configuration:any Mongo.TestConfiguration) async throws
    {
        try await self.run(under: configuration)
    }

    func run(with pool:Mongo.SessionPool) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)
        do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 4)
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(self.collection,
                    encoding: [
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
                against: self.database)

            #expect(response == expected)
        }

        do
        {
            let expected:Set<TagStats> = [
                .init(id: "medicine", count: 1),
                .init(id: "neuroscience", count: 1),
                .init(id: "education", count: 1),
                .init(id: "history", count: 3),
                .init(id: "politics", count: 1),
                .init(id: "autobiography", count: 2),
            ]
            let response:[TagStats] = try await session.run(
                command: Mongo.Aggregate<Mongo.Cursor<TagStats>>.init(self.collection,
                    writeConcern: .majority,
                    readConcern: .majority,
                    stride: 10)
                {
                    $0[stage: .project, using: Article.CodingKey.self] { $0[.tags] = true }
                    $0[stage: .unwind] = Article[.tags]
                    $0[stage: .group] = .init
                    {
                        $0[.id] = Article[.tags]

                        $0[TagStats[.count]] = .init { $0[.sum] = 1 }
                    }
                },
                against: self.database)
            {
                try await $0.reduce(into: []) { $0 += $1 }
            }

            #expect(Set<TagStats>.init(response) == expected)
        }

        do
        {
            let expected:Set<AuthorStats> = [
                .init(id: "barbie", views: 527 + 760),
                .init(id: "raquelle", views: 288 + 115),
            ]
            let response:[AuthorStats] = try await session.run(
                command: Mongo.Aggregate<Mongo.Cursor<AuthorStats>>.init(self.collection,
                    writeConcern: .majority,
                    readConcern: .majority,
                    stride: 10)
                {
                    $0[stage: .project, using: Article.CodingKey.self]
                    {
                        $0[.author] = true
                        $0[.views] = true
                    }
                    $0[stage: .group] = .init
                    {
                        $0[.id] = Article[.author]

                        $0[Article[.views]] = .init { $0[.sum] = Article[.views] }
                    }
                },
                against: self.database)
            {
                try await $0.reduce(into: []) { $0 += $1 }
            }

            #expect(Set<AuthorStats>.init(response) == expected)
        }

        #expect(try await session.stats(collection: self.database | self.collection) != nil)
    }
}
