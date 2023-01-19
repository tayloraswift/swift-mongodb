import MongoDB
import MongoChannel
import Testing

func TestCausalConsistency(_ tests:inout Tests,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<Mongo.Host>) async
{
    await tests.withTemporaryDatabase(name: "causal-consistency",
        bootstrap: bootstrap,
        hosts: hosts)
    {
        (tests:inout Tests, pool:Mongo.SessionPool, database:Mongo.Database) in

        try await pool.withSession
        {
            (session:Mongo.Session) in

            let collection:Mongo.Collection = "letters"
            let a:Letter = "a"
            let b:Letter = "b"

            //  The test deployment has six members, including one arbiter,
            //  one (non-voting) hidden replica, and four visible replicas.
            //  Therefore, writes must propogate to at least three replicas
            //  (besides the hidden replica) to pass a `majority` write
            //  concern.
            await tests.test(name: "initialize")
            {
                let response:Mongo.InsertResponse = try await session.run(
                    command: Mongo.Insert<[Letter]>.init(collection: collection,
                        elements: [a],
                        writeConcern: .init(
                            //  ensure the write propogates to *all* the visible replicas.
                            level: .acknowledged(by: 4), 
                            journaled: true)),
                    against: database,
                    on: .primary)
                
                $0.assert(response ==? .init(inserted: 1), name: "a")
            }

            //  Choose this specific secondary, which we know will always be a
            //  secondary, because it is not a citizen.
            let secondary:Mongo.ReadPreference = .secondary(
                tagSets: [["priority": "zero", "name": "C"]])

            //  Lock this secondary, without removing it from quorum. Until this
            //  secondary is unlocked, writes must propogate to all three of the
            //  other (non-hidden) replicas to pass a `majority` write concern.
            var lock:Mongo.FsyncLock = try await session.run(
                command: Mongo.Fsync.init(lock: true),
                against: .admin,
                on: secondary)

            tests.assert(lock.count ==? 1, name: "lock-count-locked")

            //  We can read the `a`, because this secondary acknowledged the
            //  write that added it to the collection.
            await tests.test(name: "before")
            {
                let letters:[Letter] = try await session.run(
                    command: Mongo.Find<Letter>.SingleBatch.init(
                        collection: collection,
                        limit: 10),
                    against: database,
                    on: secondary)
                $0.assert(letters ..? [a], name: "letters")
            }
            //  Insert a letter `b` into the collection (on the primary), using
            //  a majority write concern. This succeeds because there are still
            //  three unlocked members able to acknowledge the write.
            await tests.test(name: "insert")
            {
                let response:Mongo.InsertResponse = try await session.run(
                    command: Mongo.Insert<[Letter]>.init(collection: collection,
                        elements: [b],
                        writeConcern: .init(level: .majority, journaled: true)),
                    against: database,
                    on: .primary)
                
                $0.assert(response ==? .init(inserted: 1), name: "b")
            }

            //  Attempt to read from a different secondary.
            await tests.test(name: "bystander")
            {
                let letters:[Letter] = try await session.run(
                    command: Mongo.Find<Letter>.SingleBatch.init(
                        collection: collection,
                        limit: 10),
                    against: database,
                    on: .secondary(tagSets: [["name": "D"]]))
                
                $0.assert(letters ..? [a, b], name: "letters")
            }
            //  Attempt to read from the locked secondary from the current session.
            //  Because we are using a causally-consistent session, this will error.
            await tests.test(name: "during",
                expecting: MongoChannel.TimeoutError.init(sent: true))
            {
                _ in
                let _:[Letter] = try await session.run(
                    command: Mongo.Find<Letter>.SingleBatch.init(
                        collection: collection,
                        limit: 10),
                    against: database,
                    on: secondary)
            }
            //  Attempt to read from the locked secondary from a different session.
            //  Because that session’s timeline has no relationship with the
            //  current session’s timeline, the read succeeds, and returns the
            //  (stale) data from before the insertion of the letter `b`.
            await tests.test(name: "non-causal")
            {
                let letters:[Letter] = try await pool.run(
                    command: Mongo.Find<Letter>.SingleBatch.init(
                        collection: collection,
                        limit: 10),
                    against: database,
                    on: secondary)
                
                $0.assert(letters ..? [a], name: "letters")
            }

            lock = try await session.run(command: Mongo.FsyncUnlock.init(),
                against: .admin,
                on: secondary)
            
            tests.assert(lock.count ==? 0, name: "lock-count-unlocked")

            //  Attempt to read from the unlocked secondary from the current session.
            //  This should succeed now.
            await tests.test(name: "after")
            {
                let letters:[Letter] = try await session.run(
                    command: Mongo.Find<Letter>.SingleBatch.init(
                        collection: collection,
                        limit: 10),
                    against: database,
                    on: secondary)
                
                $0.assert(letters ..? [a, b], name: "letters")
            }
        }
    }
}
