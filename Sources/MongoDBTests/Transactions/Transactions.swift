import BSON
import MongoDB
import MongoTesting

struct Transactions<Configuration>:MongoTestBattery where Configuration:MongoTestConfiguration
{
    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let bystander:Mongo.Session = try await .init(from: pool)
        let session:Mongo.Session = try await .init(from: pool)

        let collection:Mongo.Collection = "letters"
        let a:Letter = "a"
        let b:Letter = "b"

        //  We should be able to observe that no transaction is currently in
        //  progress.
        tests.expect(session.transaction.phase ==? .autocommitting)
        //  We are using a virgin session, so its transaction number should be
        //  zero.
        tests.expect(session.transaction.number ==? 0)

        do
        {
            let tests:TestGroup = tests ! "abortion-cancelled"
            //  We should be able to abort an empty transaction by throwing an error.
            let result:Mongo.TransactionResult<Void> = await session.withSnapshotTransaction(
                writeConcern: .majority)
            {
                (_:Mongo.Transaction) in
                throw CancellationError.init()
            }
            //  We should be able to observe the transaction API return a 'cancelled'
            //  transaction result.
            switch result
            {
            case .abortion(_, .cancelled):
                tests.expect(true: true)
            case _:
                tests.expect(true: false)
            }

            //  Because the transaction was empty, the session’s transaction number
            //  should still be zero.
            tests.expect(session.transaction.number ==? 0)

            //  Because no commands were run, the session should have no precondition
            //  time.
            tests.expect(nil: session.preconditionTime)
        }

        //  We should run at least one command with the session, so that it
        //  has a precondition time.
        await (tests ! "refresh-sessions").do
        {
            try await session.refresh()
        }

        do
        {
            let tests:TestGroup = tests ! "abortion"

            //  We should be able to abort a non-empty transaction by throwing an error.
            let result:Mongo.TransactionResult<Void> = await session.withSnapshotTransaction(
                writeConcern: .majority)
            {
                (transaction:Mongo.Transaction) in
                //  We should be able to observe a precondition time associated with
                //  this transaction, because we have used its underlying session
                //  before.
                let _:BSON.Timestamp? = tests.expect(value: transaction.preconditionTime)
                //  We should be able to start a transaction with a write command,
                //  even though it also has a non-nil precondition time.
                await (tests ! "insert").do
                {
                    let response:Mongo.InsertResponse = try await transaction.run(
                        command: Mongo.Insert.init(collection, encoding: [a]),
                        against: database)

                    tests.expect(response ==? .init(inserted: 1))
                }
                //  We should be able to observe unaborted writes from the
                //  transaction itself while the transaction is ongoing, because
                //  its underlying session is causally-consistent.
                await (tests ! "find-inside").do
                {
                    let letters:[Letter] = try await transaction.run(
                        command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                            limit: 10),
                        against: database)

                    tests.expect(letters ..? [a])
                }

                bystander.synchronize(with: session)
                //  We should not be able to observe unaborted writes from other
                //  sessions while the transaction is ongoing.
                await (tests ! "find-bystander").do
                {
                    let letters:[Letter] = try await bystander.run(
                        command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                            limit: 10),
                        against: database,
                        on: .primary)

                    tests.expect(letters ..? [])
                }

                throw CancellationError.init()
            }
            //  We should be able to observe the transaction API return a 'aborted'
            //  transaction result.
            switch result
            {
            case .abortion(_, .aborted):
                tests.expect(true: true)
            case _:
                tests.expect(true: false)
            }
            //  We should be able to observe that the session’s transaction number
            //  was incremented, because the transaction was not empty.
            tests.expect(session.transaction.number ==? 1)
            //  This should not have affected the bystander session’s transaction
            //  state.
            tests.expect(bystander.transaction.number ==? 0)

            //  We should be able to verify that collection has been rolled back
            //  to its previous state.
            await (tests ! "find-outside").do
            {
                let letters:[Letter] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                        limit: 10),
                    against: database,
                    on: .primary)

                tests.expect(letters ..? [])
            }
        }
        do
        {
            let tests:TestGroup = tests ! "commit-cancelled"
            //  We should be able to commit an empty transaction, by returning from
            //  the closure argument.
            let result:Mongo.TransactionResult<Void> = await session.withSnapshotTransaction(
                writeConcern: .majority)
            {
                (_:Mongo.Transaction) in
            }
            //  We should be able to observe the transaction API return a 'cancelled'
            //  transaction result.
            switch result
            {
            case .commit(_, .cancelled):
                tests.expect(true: true)
            case _:
                tests.expect(true: false)
            }

            //  We should be able to observe that the session’s transaction number
            //  stayed the same, because the transaction was empty.
            tests.expect(session.transaction.number ==? 1)
        }
        do
        {
            let tests:TestGroup = tests ! "commit"
            //  We should be able to commit a non-empty transaction, by returning from
            //  the closure argument.
            let result:Mongo.TransactionResult<Void> = await session.withSnapshotTransaction(
                writeConcern: .majority)
            {
                (transaction:Mongo.Transaction) in

                await (tests ! "insert").do
                {
                    let response:Mongo.InsertResponse = try await transaction.run(
                        command: Mongo.Insert.init(collection, encoding: [b]),
                        against: database)

                    tests.expect(response ==? .init(inserted: 1))
                }
                //  We should be able to observe uncommitted writes from the
                //  transaction itself while the transaction is ongoing.
                await (tests ! "find-inside").do
                {
                    let letters:[Letter] = try await transaction.run(
                        command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                            limit: 10),
                        against: database)

                    tests.expect(letters ..? [b])
                }

                bystander.synchronize(with: session)
                //  We should not be able to observe uncommitted writes from other
                //  sessions while the transaction is ongoing.
                await (tests ! "find-inside-bystander").do
                {
                    let letters:[Letter] = try await bystander.run(
                        command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                            limit: 10),
                        against: database,
                        on: .primary)

                    tests.expect(letters ..? [])
                }
            }
            //  We should be able to observe the transaction API return a 'committed'
            //  transaction result.
            switch result
            {
            case .commit(_, .committed):
                tests.expect(true: true)
            case _:
                tests.expect(true: false)
            }
            //  We should be able to observe that the session’s transaction number
            //  was incremented, because the transaction was not empty.
            tests.expect(session.transaction.number ==? 2)
            //  This should not have affected the bystander session’s transaction
            //  state.
            tests.expect(bystander.transaction.number ==? 0)
            //  We should synchronize the bystander session, so that reads using it
            //  will be aware that the transaction was committed.
            bystander.synchronize(with: session)

            //  We should be able to verify that collection has changed. The writes
            //  should be durable, because we used a majority write concern, and
            //  and we should be able to observe them because we are using a
            //  causally-consistent session.
            await (tests ! "find-outside").do
            {
                let letters:[Letter] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection, limit: 10),
                    against: database,
                    on: .primary)

                tests.expect(letters ..? [b])
            }
            //  We should also be able to observe the committed writes from the
            //  bystander session.
            await (tests ! "find-outside-bystander").do
            {
                let letters:[Letter] = try await bystander.run(
                    command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection, limit: 10),
                    against: database,
                    on: .primary)

                tests.expect(letters ..? [b])
            }
        }
    }
}
