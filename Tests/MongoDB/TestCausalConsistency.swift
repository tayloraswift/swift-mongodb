import MongoDB
import Testing

func TestCausalConsistency(_ tests:inout Tests,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<Mongo.Host>) async
{
    await tests.test(with: DatabaseEnvironment.init(bootstrap: bootstrap,
        database: "causal-consistency",
        hosts: hosts))
    {
        (tests:inout Tests, context:DatabaseEnvironment.Context) in

        try await context.pool.withSession
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
                    against: context.database,
                    on: .primary)
                
                $0.assert(response ==? .init(inserted: 1), name: "a")
            }

            //  choose this specific secondary, which we know will always
            //  be a secondary, because it is not a citizen.
            let secondary:Mongo.ReadPreference = .secondary(
                tagSets: [["priority": "zero", "name": "C"]])

            // print(try await context.pool.run(command: Mongo.FsyncUnlock.init(), on: secondary))

            var lock:Mongo.FsyncLock
            //  Lock this secondary, without removing it from quorum. Until this
            //  secondary is unlocked, writes must propogate to all three of the
            //  other (non-hidden) replicas to pass a `majority` write concern.
            lock = try await session.run(command: Mongo.Fsync.init(lock: true),
                against: .admin,
                on: secondary)

            tests.assert(lock.count ==? 1, name: "lock-count-locked")

            await tests.test(name: "before")
            {
                let letters:[Letter] = try await session.run(
                    command: Mongo.Find<Letter>.SingleBatch.init(
                        collection: collection,
                        limit: 10),
                    against: context.database,
                    on: secondary)
                $0.assert(letters ..? [a], name: "letters")
            }
            
            await tests.test(name: "insert")
            {
                let response:Mongo.InsertResponse = try await session.run(
                    command: Mongo.Insert<[Letter]>.init(collection: collection,
                        elements: [b],
                        writeConcern: .init(level: .majority, journaled: true)),
                    against: context.database,
                    on: .primary)
                
                $0.assert(response ==? .init(inserted: 1), name: "b")
            }

            // await tests.test(name: "during")
            // {
            //     let letters:[Letter] = try await session.run(
            //         command: Mongo.Find<Letter>.SingleBatch.init(
            //             collection: collection,
            //             limit: 10),
            //         against: context.database,
            //         on: secondary)
                
            //     $0.assert(letters ..? [a, b], name: "letters")
            // }

            lock = try await session.run(command: Mongo.FsyncUnlock.init(),
                against: .admin,
                on: secondary)

            tests.assert(lock.count ==? 0, name: "lock-count-unlocked")
        }
    }
}
