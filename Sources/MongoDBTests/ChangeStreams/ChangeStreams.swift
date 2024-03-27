import BSON
import MongoDB
import MongoTesting

struct ChangeStreams<Configuration>:MongoTestBattery where Configuration:MongoTestConfiguration
{
    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let collection:Mongo.Collection = "watchable"
        await tests.do
        {
            let session:Mongo.Session = try await .init(from: pool)
            try await session.run(
                command: Mongo.Aggregate<Mongo.Cursor<BSON.Document>>.init(collection,
                    writeConcern: .majority,
                    readConcern: .majority,
                    stride: 10)
                {
                    $0[stage: .changeStream] { _ in }
                },
                against: database,
                by: .now.advanced(by: .seconds(15)))
            {
                for try await _:[BSON.Document] in $0
                {
                    return
                }
            }
        }
    }
}
