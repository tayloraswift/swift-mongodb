import MongoDB
import MongoChannel
import Testing

func TestTransactions(_ tests:TestGroup,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<Mongo.Host>) async
{
    let tests:TestGroup = tests / "transactions"

    await tests.withTemporaryDatabase(named: "transaction-tests",
        bootstrap: bootstrap,
        hosts: hosts)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        let session:Mongo.Session = try await .init(from: pool)

        let collection:Mongo.Collection = "letters"
        let a:Letter = "a"

        try await session.withTransaction(
            writeConcern: .init(level: .majority),
            readConcern: .snapshot)
        {
            (transaction:Mongo.TransactionContext) in

            await (tests / "insert").do
            {
                let response:Mongo.InsertResponse = try await transaction.run(
                    command: Mongo.Insert<[Letter]>.init(collection: collection,
                        elements: [a]),
                    against: database)
                
                tests.expect(response ==? .init(inserted: 1))
            }

            await (tests / "find").do
            {
                let letters:[Letter] = try await transaction.run(
                    command: Mongo.Find<Letter>.SingleBatch.init(
                        collection: collection,
                        limit: 10),
                    against: database)
                
                tests.expect(letters ..? [a])
            }
        }
    }
}
