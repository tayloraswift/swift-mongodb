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

        let session:Mongo.Session = try await .init(from: pool)

        let collection:Mongo.Collection = "letters"
        let a:Letter = "a"
        let b:Letter = "b"
        let c:Letter = "c"
        let d:Letter = "d"

        //  We should have a test deployment with six members, including one
        //  arbiter, one (non-voting) hidden replica, and four visible
        //  replicas.
        // 
        //  Therefore, writes must propogate to at least three replicas
        //  (besides the hidden replica) to pass a `majority` write concern.
        await tests.test(name: "initialize")
        {
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert<[Letter]>.init(collection: collection,
                    elements: [a],
                    writeConcern: .init(
                        //  We should ensure the write propogates to all four visible replicas.
                        level: .acknowledged(by: 4), 
                        journaled: true)),
                against: database,
                on: .primary)
            
            $0.assert(response ==? .init(inserted: 1), name: "a")
        }

        //  We should be able to choose this specific secondary/slave, which
        //  we know will always be a secondary/slave, because it is not a
        //  citizen.
        let secondary:Mongo.ReadPreference = .secondary(
            tagSets: [["priority": "zero", "name": "C"]])

        //  We should be able to lock this secondary/slave, without removing
        //  it from quorum. Until this secondary is unlocked, writes must
        //  propogate to all three of the other (non-hidden) replicas to pass
        //  a `majority` write concern.
        var lock:Mongo.FsyncLock = try await session.run(
            command: Mongo.Fsync.init(lock: true),
            against: .admin,
            on: secondary)

        tests.assert(lock.count ==? 1, name: "lock-count-locked")

        //  We should be able to fix the test deployment if a previous run
        //  of this test got interrupted.
        for count:Int in (1 ..< lock.count).reversed()
        {
            lock = try await session.run(command: Mongo.FsyncUnlock.init(),
                against: .admin,
                on: secondary)
            
            tests.assert(lock.count ==? count, name: "lock-count-cleanup")
        }

        //  We should be able to read the `a`, because this secondary/slave
        //  acknowledged the write that added it to the collection before we
        //  locked it.
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
        //  We should be able to insert a letter `b` into the collection (on
        //  the primary/master), using a majority write concern. We should
        //  succeed because there are still three unlocked members able to
        //  acknowledge the write.
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
        //  We should be able to insert a letter `c` into the collection (on
        //  the primary/master), using an acknowledgement count write concern.
        //  We should succeed because three acknowledgements is currently the
        //  threshold needed to pass a majority write concern.
        await tests.test(name: "insert")
        {
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert<[Letter]>.init(collection: collection,
                    elements: [c],
                    writeConcern: .init(level: .acknowledged(by: 3), journaled: true)),
                against: database,
                on: .primary)
            
            $0.assert(response ==? .init(inserted: 1), name: "c")
        }
        //  We should be able to insert a letter `d` into the collection (on the
        //  primary/master), using an acknowledgement count write concern that
        //  is lower than the current majority threshold. We should succeed
        //  because this insertion should also have been able to pass a majority
        //  write concern.
        await tests.test(name: "insert")
        {
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert<[Letter]>.init(collection: collection,
                    elements: [d],
                    writeConcern: .init(level: .acknowledged(by: 2), journaled: true)),
                against: database,
                on: .primary)
            
            $0.assert(response ==? .init(inserted: 1), name: "d")
        }

        //  We should be able to capture a reference to a session and a command
        //  from a non-sendable closure, and call that in lieu of using the
        //  session directly.
        //
        //  We should be able to use said closure to try to read from the locked
        //  secondary.
        func ReadLetters() async throws -> [Letter]
        {
            try await session.run(
                command: Mongo.Find<Letter>.SingleBatch.init(
                    collection: collection,
                    limit: 10),
                against: database,
                on: secondary,
                by: .now.advanced(by: .milliseconds(500)))
        }

        //  We should receive a timeout error if we try to read from the locked
        //  secondary/slave from the current session, because sessions are
        //  causally-consistent.
        //
        //  When we used the session to write to the primary/master, we should
        //  have updated the session’s precondition time to the operation time
        //  reported by the primary/master. When we try to read from the locked
        //  secondary, we should be asking it for data from a time in its future
        //  that it doesn’t have. We should have prevented it from getting the
        //  new data by locking it earlier.
        await tests.test(name: "timeout",
            expecting: MongoChannel.TimeoutError.init(sent: true))
        {
            _ in
            let _:[Letter] = try await ReadLetters()
        }

        //  We should be able to read all four writes from a different,
        //  unlocked secondary/slave.
        await tests.test(name: "bystander")
        {
            let letters:[Letter] = try await session.run(
                command: Mongo.Find<Letter>.SingleBatch.init(
                    collection: collection,
                    limit: 10),
                against: database,
                on: .secondary(tagSets: [["name": "D"]]))
            
            $0.assert(letters ..? [a, b, c, d], name: "letters")
        }

        //  We should still receive a timeout error if we try to read from the
        //  locked secondary from the current session, because running the last
        //  command didn’t lower the precondition time.
        await tests.test(name: "timeout-again",
            expecting: MongoChannel.TimeoutError.init(sent: true))
        {
            _ in
            let _:[Letter] = try await ReadLetters()
        }
        //  We should still be able to read from the locked secondary/slave from
        //  a different session. Because that session’s timeline should have no
        //  relationship with the current session’s timeline, the read should
        //  succeed, and return the stale data from before the last three writes.
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

        //  We should be able to unlock the secondary/slave.
        lock = try await session.run(command: Mongo.FsyncUnlock.init(),
            against: .admin,
            on: secondary)
        //  We should have unlocked the secondary/slave all the way.
        tests.assert(lock.count ==? 0, name: "lock-count-unlocked")

        //  We should be able to read all four writes from the unlocked
        //  secondary/slave, because it has caught up to the session’s
        //  precondition time.
        tests.assert(try await ReadLetters() ..? [a, b, c, d], name: "all-letters")
    }
}
