import BSON
import MongoDB
import MongoTesting

extension ChangeStreams
{
    struct Ticket
    {
        let id:Int
        let value:String

        init(id:Int, value:String)
        {
            self.id = id
            self.value = value
        }
    }
}
extension ChangeStreams.Ticket:MongoMasterCodingModel
{
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case value = "v"
    }
}
extension ChangeStreams.Ticket:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.value] = self.value
    }
}
extension ChangeStreams.Ticket:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(), value: try bson[.value].decode())
    }
}

struct ChangeStreams<Configuration>:MongoTestBattery where Configuration:MongoTestConfiguration
{
    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let collection:Mongo.Collection = "tickets"

        await tests.do
        {
            let session:Mongo.Session = try await .init(from: pool)
            try await session.run(
                command: Mongo.Aggregate<Mongo.Cursor<BSON.Document>>.init(collection,
                    writeConcern: .majority,
                    readConcern: .majority,
                    //  This is always needed, otherwise the cursor will die after a fixed
                    //  amount of time.
                    tailing: .init(timeout: 5_000, awaits: true),
                    stride: 10)
                {
                    $0[stage: .changeStream] { _ in }
                },
                against: database,
                by: .now.advanced(by: .seconds(15)))
            {
                var poll:Int = 0
                for try await batch:[BSON.Document] in $0
                {
                    defer
                    {
                        poll += 1
                    }
                    if  poll == 0
                    {
                        tests.expect(batch.count ==? 0)
                    }
                    else if
                        let document:BSON.Document = batch.first
                    {
                        print(document)
                        return
                    }
                    else if poll > 5
                    {
                        //  If more than 5 polling intervals have passed and we still haven't
                        //  received any documents, then the test has failed.
                        tests.expect(true: false)
                    }

                    let _:Task<Void, any Error> = .init
                    {
                        let session:Mongo.Session = try await .init(from: pool)

                        let document:Ticket = .init(id: 1, value: "a")
                        let _:Mongo.InsertResponse = try await session.run(
                            command: Mongo.Insert.init(collection, encoding: [document]),
                            against: database)
                    }
                }
            }
        }
    }
}
