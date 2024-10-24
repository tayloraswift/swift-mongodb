import MongoDB
import Testing

@Suite
struct Find:Mongo.TestBattery
{
    let collection:Mongo.Collection = "ordinals"
    let database:Mongo.Database = "Find"

    private
    let ordinals:Ordinals = .init(identifiers: 0 ..< 100)

    @Test(arguments: [.single, .replicated] as [any Mongo.TestConfiguration])
    func find(_ configuration:any Mongo.TestConfiguration) async throws
    {
        try await self.run(under: configuration)
    }

    func run(with pool:Mongo.SessionPool) async throws
    {
        do
        {
            let expected:Mongo.InsertResponse = .init(inserted: 100)
            let response:Mongo.InsertResponse = try await pool.run(
                command: Mongo.Insert.init(self.collection, encoding: ordinals),
                against: self.database)

            #expect(response == expected)
        }
        do
        {
            let response:[Record<Int64>] = try await pool.run(
                command: Mongo.Find<Mongo.SingleBatch<Record<Int64>>>.init(self.collection,
                    limit: 10),
                against: self.database)

            #expect(response == [_].init(ordinals.prefix(10)))
        }
        do
        {
            let response:[Record<Int64>] = try await pool.run(
                command: Mongo.Find<Mongo.SingleBatch<Record<Int64>>>.init(self.collection,
                    limit: 7,
                    skip: 5),
                against: self.database)

            #expect(response == [_].init(ordinals[5 ..< 12]))
        }
        do
        {
            let response:[Record<Int64>] = try await pool.run(
                command: Mongo.Find<Mongo.SingleBatch<Record<Int64>>>.init(self.collection,
                    limit: 5,
                    skip: 10)
                {
                    $0[.hint, using: Record<Int64>.CodingKey.self]
                    {
                        $0[.id] = (+)
                    }
                },
                against: self.database)

            #expect(response == [_].init(ordinals[10 ..< 15]))
        }
        do
        {
            let response:[Record<Int64>] = try await pool.run(
                command: Mongo.Find<Mongo.SingleBatch<Record<Int64>>>.init(self.collection,
                    limit: 5,
                    skip: 10)
                {
                    $0[.sort, using: Record<Int64>.CodingKey.self]
                    {
                        $0[.value] = (-)
                    }
                },
                against: self.database)

            #expect(response == [_].init(ordinals[85 ..< 90].reversed()))
        }
        do
        {
            let session:Mongo.Session = try await .init(from: pool)
            try await session.run(
                command: Mongo.Find<Mongo.Cursor<Record<Int64>>>.init(self.collection,
                    stride: 10),
                against: self.database)
            {
                var expected:Ordinals.Iterator = ordinals.makeIterator()
                for try await batch:[Record<Int64>] in $0
                {
                    for returned:Record<Int64> in batch
                    {
                        #expect(returned == expected.next())
                    }
                }

                #expect(expected.next() == nil)
            }
        }
        do
        {
            let session:Mongo.Session = try await .init(from: pool)
            try await session.run(
                command: Mongo.Find<Mongo.Cursor<Record<Int64>>>.init(self.collection,
                    stride: 10)
                {
                    $0[.filter]
                    {
                        $0["value"] { $0[.mod] = (by: 3, is: 0) }
                    }
                },
                against: self.database)
            {
                var expected:Array<Record<Int64>>.Iterator =
                    ordinals.filter { $0.value % 3 == 0 }.makeIterator()
                for try await batch:[Record<Int64>] in $0
                {
                    for returned:Record<Int64> in batch
                    {
                        #expect(returned == expected.next())
                    }
                }

                #expect(expected.next() == nil)
            }
        }
        do
        {
            let session:Mongo.Session = try await .init(from: pool)
            try await session.run(
                command: Mongo.Find<Mongo.Cursor<Record<Int64>>>.init(self.collection,
                    stride: 10)
                {
                    $0[.projection, using: Record<Int64>.CodingKey.self]
                    {
                        $0[.id] = true
                        $0[.value] { $0[.add] = ("$value", 5) }
                    }
                },
                against: self.database)
            {
                var expected:Ordinals.Iterator = Ordinals.init(
                    identifiers: 0 ..< 100,
                    start: 5).makeIterator()
                for try await batch:[Record<Int64>] in $0
                {
                    for returned:Record<Int64> in batch
                    {
                        #expect(returned == expected.next())
                    }
                }

                #expect(expected.next() == nil)
            }
        }
    }
}
