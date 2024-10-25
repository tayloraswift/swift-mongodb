import MongoDB
import Testing

@Suite
struct Collation:Mongo.TestBattery
{
    let collection:Mongo.Collection = "Rulers"
    let database:Mongo.Database = "Collation"

    @Test(arguments: [.single, .replicated] as [any Mongo.TestConfiguration])
    func collation(_ configuration:any Mongo.TestConfiguration) async throws
    {
        try await self.run(under: configuration)
    }

    func run(with pool:Mongo.SessionPool) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)
        let rulers:[Ruler] = [
            .init(id: "Jeanine Áñez Chávez",
                party: "Demócratas",
                since: 2019),

            .init(id: "Jürgen Coße",
                party: "SPD",
                since: 2016),

            .init(id: "Ilham Heydar oghlu Aliyev",
                party: "Yeni Azərbaycan Partiyası",
                since: 2003),
        ]

        do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 3)
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(self.collection, encoding: rulers),
                against: self.database)

            #expect(response == expected)
        }
        do
        {
            let match:Ruler? = try await session.run(
                command: Mongo.Find<Mongo.Single<Ruler>>.init(self.collection, limit: 1)
                {
                    $0[.filter]
                    {
                        $0["_id"] = "jeanine áñez chávez"
                    }
                    $0[.collation] = .init(locale: "en", strength: .secondary)
                },
                against: self.database)

            #expect(match == rulers[0])
        }
        do
        {
            let match:Ruler? = try await session.run(
                command: Mongo.Find<Mongo.Single<Ruler>>.init(self.collection, limit: 1)
                {
                    $0[.filter]
                    {
                        $0["_id"] = "jürgen coße"
                    }
                    $0[.collation] = .init(locale: "en", strength: .secondary)
                },
                against: self.database)

            #expect(match == rulers[1])
        }
        do
        {
            let match:Ruler? = try await session.run(
                command: Mongo.Find<Mongo.Single<Ruler>>.init(self.collection, limit: 1)
                {
                    $0[.filter]
                    {
                        $0["_id"] = "ılham heydar oghlu aliyev"
                    }
                    $0[.collation] = .init(locale: "en", strength: .secondary)
                },
                against: self.database)

            #expect(match == nil)
        }
        do
        {
            let match:Ruler? = try await session.run(
                command: Mongo.Find<Mongo.Single<Ruler>>.init(self.collection, limit: 1)
                {
                    $0[.filter]
                    {
                        $0["_id"] = "ilham heydar oghlu aliyev"
                    }
                    $0[.collation] = .init(locale: "en", strength: .secondary)
                },
                against: self.database)

            #expect(match == rulers[2])
        }
        do
        {
            let match:Ruler? = try await session.run(
                command: Mongo.Find<Mongo.Single<Ruler>>.init(self.collection, limit: 1)
                {
                    $0[.filter]
                    {
                        $0["_id"] = "ılham heydar oghlu aliyev"
                    }
                    $0[.collation] = .init(locale: "tr", strength: .secondary)
                },
                against: self.database)

            #expect(match == rulers[2])
        }
        do
        {
            let match:Ruler? = try await session.run(
                command: Mongo.Find<Mongo.Single<Ruler>>.init(self.collection, limit: 1)
                {
                    $0[.filter]
                    {
                        $0["_id"] = "ilham heydar oghlu aliyev"
                    }
                    $0[.collation] = .init(locale: "tr", strength: .secondary)
                },
                against: self.database)

            #expect(match == nil)
        }
    }
}
