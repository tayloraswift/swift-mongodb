import BSON
import MongoDB
import Testing

@Suite
struct Transactions:Mongo.TestBattery
{
    let database:Mongo.Database = "Transactions"

    //  Transactions only work with replica sets.
    @Test(arguments: [.replicated] as [any Mongo.TestConfiguration])
    func transactions(_ configuration:any Mongo.TestConfiguration) async throws
    {
        try await self.run(under: configuration)
    }

    func run(with pool:Mongo.SessionPool) async throws
    {
        let bystander:Mongo.Session = try await .init(from: pool)
        let session:Mongo.Session = try await .init(from: pool)

        let collection:Mongo.Collection = "letters"
        let a:Letter = "a"
        let b:Letter = "b"

        //  We should be able to observe that no transaction is currently in
        //  progress.
        #expect(session.transaction.phase == .autocommitting)
        //  We are using a virgin session, so its transaction number should be
        //  zero.
        #expect(session.transaction.number == 0)

        do
        {
            //  We should be able to abort an empty transaction by throwing an error.
            let result:Mongo.TransactionResult<Void> = await session.withSnapshotTransaction(
                writeConcern: .majority)
            {
                (_:Mongo.Transaction) in throw CancellationError.init()
            }
            //  We should be able to observe the transaction API return a 'cancelled'
            //  transaction result.
            switch result
            {
            case .abortion(_, .cancelled):  #expect(true)
            case _:                         #expect(false as Bool)
            }

            //  Because the transaction was empty, the session’s transaction number
            //  should still be zero.
            #expect(session.transaction.number == 0)

            //  Because no commands were run, the session should have no precondition
            //  time.
            #expect(session.preconditionTime == nil)
        }

        //  We should run at least one command with the session, so that it
        //  has a precondition time.
        try await session.refresh()

        do
        {
            //  We should be able to abort a non-empty transaction by throwing an error.
            let result:Mongo.TransactionResult<Void> = await session.withSnapshotTransaction(
                writeConcern: .majority)
            {
                (transaction:Mongo.Transaction) in
                //  We should be able to observe a precondition time associated with
                //  this transaction, because we have used its underlying session
                //  before.
                #expect(transaction.preconditionTime != nil)
                //  We should be able to start a transaction with a write command,
                //  even though it also has a non-nil precondition time.
                do
                {
                    let response:Mongo.InsertResponse = try await transaction.run(
                        command: Mongo.Insert.init(collection, encoding: [a]),
                        against: self.database)

                    #expect(response == .init(inserted: 1))
                }
                //  We should be able to observe unaborted writes from the
                //  transaction itself while the transaction is ongoing, because
                //  its underlying session is causally-consistent.
                do
                {
                    let letters:[Letter] = try await transaction.run(
                        command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                            limit: 10),
                        against: self.database)

                    #expect(letters == [a])
                }

                bystander.synchronize(with: session)
                //  We should not be able to observe unaborted writes from other
                //  sessions while the transaction is ongoing.
                do
                {
                    let letters:[Letter] = try await bystander.run(
                        command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                            limit: 10),
                        against: self.database,
                        on: .primary)

                    #expect(letters == [])
                }

                throw CancellationError.init()
            }
            //  We should be able to observe the transaction API return a 'aborted'
            //  transaction result.
            switch result
            {
            case .abortion(_, .aborted):    #expect(true)
            case _:                         #expect(false as Bool)
            }
            //  We should be able to observe that the session’s transaction number
            //  was incremented, because the transaction was not empty.
            #expect(session.transaction.number == 1)
            //  This should not have affected the bystander session’s transaction
            //  state.
            #expect(bystander.transaction.number == 0)

            //  We should be able to verify that collection has been rolled back
            //  to its previous state.
            do
            {
                let letters:[Letter] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                        limit: 10),
                    against: self.database,
                    on: .primary)

                #expect(letters == [])
            }
        }
        do
        {
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
            case .commit(_, .cancelled):    #expect(true)
            case _:                         #expect(false as Bool)
            }

            //  We should be able to observe that the session’s transaction number
            //  stayed the same, because the transaction was empty.
            #expect(session.transaction.number == 1)
        }
        do
        {
            //  We should be able to commit a non-empty transaction, by returning from
            //  the closure argument.
            let result:Mongo.TransactionResult<Void> = await session.withSnapshotTransaction(
                writeConcern: .majority)
            {
                (transaction:Mongo.Transaction) in

                do
                {
                    let response:Mongo.InsertResponse = try await transaction.run(
                        command: Mongo.Insert.init(collection, encoding: [b]),
                        against: self.database)

                    #expect(response == .init(inserted: 1))
                }
                //  We should be able to observe uncommitted writes from the
                //  transaction itself while the transaction is ongoing.
                do
                {
                    let letters:[Letter] = try await transaction.run(
                        command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                            limit: 10),
                        against: self.database)

                    #expect(letters == [b])
                }

                bystander.synchronize(with: session)
                //  We should not be able to observe uncommitted writes from other
                //  sessions while the transaction is ongoing.
                do
                {
                    let letters:[Letter] = try await bystander.run(
                        command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                            limit: 10),
                        against: self.database,
                        on: .primary)

                    #expect(letters == [])
                }
            }
            //  We should be able to observe the transaction API return a 'committed'
            //  transaction result.
            switch result
            {
            case .commit(_, .committed):    #expect(true)
            case _:                         #expect(false as Bool)
            }
            //  We should be able to observe that the session’s transaction number
            //  was incremented, because the transaction was not empty.
            #expect(session.transaction.number == 2)
            //  This should not have affected the bystander session’s transaction
            //  state.
            #expect(bystander.transaction.number == 0)
            //  We should synchronize the bystander session, so that reads using it
            //  will be aware that the transaction was committed.
            bystander.synchronize(with: session)

            //  We should be able to verify that collection has changed. The writes
            //  should be durable, because we used a majority write concern, and
            //  and we should be able to observe them because we are using a
            //  causally-consistent session.
            do
            {
                let letters:[Letter] = try await session.run(
                    command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection, limit: 10),
                    against: self.database,
                    on: .primary)

                #expect(letters == [b])
            }
            //  We should also be able to observe the committed writes from the
            //  bystander session.
            do
            {
                let letters:[Letter] = try await bystander.run(
                    command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection, limit: 10),
                    against: self.database,
                    on: .primary)

                #expect(letters == [b])
            }
        }
    }
}
