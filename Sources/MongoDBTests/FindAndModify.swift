import MongoDB
import Testing

@Suite
struct FindAndModify:Mongo.TestBattery
{
    let collection:Mongo.Collection = "Rulers"
    let database:Mongo.Database = "FindAndModify"

    @Test(arguments: [.single, .replicated] as [any Mongo.TestConfiguration])
    func findAndModify(_ configuration:any Mongo.TestConfiguration) async throws
    {
        try await self.run(under: configuration)
    }

    func run(with pool:Mongo.SessionPool) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)
        let states:([Ruler], Set<Ruler>, Set<Ruler>, Set<Ruler>)

        states.0 = [
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
        states.1 = [
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
        states.2 = [
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
        states.3 = [
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

        do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 4)
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(self.collection, encoding: states.0),
                against: self.database)

            #expect(response == expected)
        }
        do
        {
            let expected:Ruler = .init(id: "Dina Ercilia Boluarte Zegarra",
                party: "Independent",
                since: 2022)

            let (response, _):(Ruler?, Never?) = try await session.run(
                command: Mongo.FindAndModify<Mongo.Existing<Ruler>>.init(self.collection,
                    writeConcern: .majority,
                    returning: .new)
                    {
                        $0[.query]
                        {
                            $0["_id"] = "Dina Ercilia Boluarte Zegarra"
                        }
                        $0[.update]
                        {
                            $0[.set]
                            {
                                $0["party"] = "Independent"
                            }
                        }
                    },
                against: self.database)

            #expect(response == expected)

            let rulers:[Ruler] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Ruler>>.init(self.collection,
                    limit: 10),
                against: self.database)

            #expect(Set<Ruler>.init(rulers) == states.1)
        }
        do
        {
            let expected:Ruler = .init(id: "Marion Anne Perrine Le Pen",
                party: "Rassemblement National",
                since: 2027)
            let (response, upserted):(Ruler?, String?) = try await session.run(
                command: Mongo.FindAndModify<Mongo.Upserting<Ruler, String>>.init(
                    self.collection,
                    writeConcern: .majority,
                    returning: .new)
                    {
                        $0[.query]
                        {
                            $0["_id"] = expected.id
                        }
                        $0[.update] = expected
                    },
                against: self.database)

            #expect(response == expected)
            #expect(upserted == expected.id)

            let rulers:[Ruler] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Ruler>>.init(self.collection,
                    limit: 10),
                against: self.database)

            #expect(Set<Ruler>.init(rulers) == states.2)
        }
        do
        {
            let expected:Ruler = .init(id: "Jeanine Áñez Chávez",
                party: "Demócratas",
                since: 2019)
            let (response, _):(Ruler?, Never?) = try await session.run(
                command: Mongo.FindAndModify<Mongo.Removing<Ruler>>.init(self.collection,
                    writeConcern: .majority,
                    returning: .deleted)
                    {
                        $0[.sort, using: Ruler.CodingKey.self]
                        {
                            $0[.since] = (+)
                        }
                    },
                against: database)

            #expect(response == expected)

            let rulers:[Ruler] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Ruler>>.init(self.collection,
                    limit: 10),
                against: self.database)

            #expect(Set<Ruler>.init(rulers) == states.3)
        }
    }
}
