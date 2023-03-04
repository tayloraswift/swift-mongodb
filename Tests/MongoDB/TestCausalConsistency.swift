import MongoDB
import Testing

func TestCausalConsistency(_ tests:TestGroup,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<Mongo.Host>) async
{
    let tests:TestGroup = tests / "causal-consistency"

    await tests.withTemporaryDatabase(named: "causal-consistency-tests",
        bootstrap: bootstrap,
        logger: .init(level: .full),
        hosts: hosts)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        let session:Mongo.Session = try await .init(from: pool)

        let collection:Mongo.Collection = "letters"
        let a:Letter = "a"
        let b:Letter = "b"
        let c:Letter = "c"
        let d:Letter = "d"

        //  A new session should have no precondition time.
        tests.expect(nil: session.preconditionTime)

        //  We should have a test deployment with six members, including one
        //  arbiter, one (non-voting) hidden replica, and four visible
        //  replicas.
        // 
        //  Therefore, writes must propogate to at least three replicas
        //  (besides the hidden replica) to pass a `majority` write concern.
        await (tests / "initialize").do
        {
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(collection: collection,
                    writeConcern: .acknowledged(by: 4, journaled: true),
                    elements: [a]),
                    //  We should ensure the write propogates to all four visible replicas.
                against: database,
                on: .primary)
            
            tests.expect(response ==? .init(inserted: 1))
        }

        let other:Mongo.Session = try await .init(from: pool, forking: session)

        //  We should be able to observe a precondition time after performing the
        //  initialization.
        guard var head:Mongo.Instant = tests.expect(value: session.preconditionTime)
        else
        {
            return
        }

        //  We should be able to choose this specific secondary/slave, which
        //  we know will always be a secondary/slave, because it is not a
        //  citizen. It was configured with zero votes, so no other secondaries
        //  should be replicating from it.
        let secondary:Mongo.ReadPreference = .secondary(
            tagSets: [["priority": "zero", "name": "E"]])

        //  We should be able to lock this secondary/slave, without removing
        //  it from quorum. Until this secondary is unlocked, writes must
        //  propogate to all three of the other (non-hidden) replicas to pass
        //  a `majority` write concern.
        var lock:Mongo.FsyncLock = try await session.run(
            command: Mongo.Fsync.init(lock: true),
            against: .admin,
            on: secondary)

        tests.expect(lock.count ==? 1)

        //  We should be able to fix the test deployment if a previous run
        //  of this test got interrupted.
        for count:Int in (1 ..< lock.count).reversed()
        {
            lock = try await session.run(command: Mongo.FsyncUnlock.init(),
                against: .admin,
                on: secondary)
            
            tests.expect(lock.count ==? count)
        }

        //  We should be able to read the `a`, because this secondary/slave
        //  acknowledged the write that added it to the collection before we
        //  locked it.
        await (tests / "before").do
        {
            let letters:[Letter] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(
                    collection: collection,
                    limit: 10),
                against: database,
                on: secondary)
            tests.expect(letters ..? [a])
        }
        //  We should be able to insert a letter `b` into the collection (on
        //  the primary/master), using a majority write concern. We should
        //  succeed because there are still three unlocked members able to
        //  acknowledge the write.
        await (tests / "insert-b").do
        {
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(collection: collection,
                    writeConcern: .majority(journaled: true),
                    elements: [b]),
                against: database,
                on: .primary)
            
            tests.expect(response ==? .init(inserted: 1))
        }

        //  We should still be able to observe a precondition time, and the
        //  value of that time should be greater than it was before we inserted
        //  the letter `b` into the collection.
        if let time:Mongo.Instant = tests.expect(value: session.preconditionTime)
        {
            tests.expect(true: head < time)
            head = time
        }

        //  We should be able to insert a letter `c` into the collection (on
        //  the primary/master), using an acknowledgement count write concern.
        //  We should succeed because three acknowledgements is currently the
        //  threshold needed to pass a majority write concern.
        await (tests / "insert-c").do
        {
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(collection: collection,
                    writeConcern: .acknowledged(by: 3, journaled: true),
                    elements: [c]),
                against: database,
                on: .primary)
            
            tests.expect(response ==? .init(inserted: 1))
        }

        if let time:Mongo.Instant = tests.expect(value: session.preconditionTime)
        {
            tests.expect(true: head < time)
            head = time
        }

        //  We should be able to insert a letter `d` into the collection (on the
        //  primary/master), using an acknowledgement count write concern that
        //  is lower than the current majority threshold. We should succeed
        //  because this insertion should also have been able to pass a majority
        //  write concern.
        await (tests / "insert-d").do
        {
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(collection: collection,
                    writeConcern: .acknowledged(by: 2, journaled: true),
                    elements: [d]),
                against: database,
                on: .primary)
            
            tests.expect(response ==? .init(inserted: 1))
        }

        if let time:Mongo.Instant = tests.expect(value: session.preconditionTime)
        {
            tests.expect(true: head < time)
            head = time
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
                command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(
                    collection: collection,
                    limit: 10)
                {
                    $0[.sort] = .init
                    {
                        $0["_id"] = (+)
                    }
                },
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
        await (tests / "timeout").do(catching: Mongo.TimeoutError.self)
        {
            let _:[Letter] = try await ReadLetters()
        }

        //  We should be able to read all four writes from a different,
        //  unlocked secondary/slave.
        await (tests / "bystander").do
        {
            let letters:[Letter] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(
                    collection: collection,
                    limit: 10)
                {
                    $0[.sort] = .init
                    {
                        $0["_id"] = (+)
                    }
                },
                against: database,
                on: .secondary(tagSets: [["name": "D"]]))
            
            tests.expect(letters ..? [a, b, c, d])
        }

        //  We should still receive a timeout error if we try to read from the
        //  locked secondary from the current session, because running the last
        //  command didn’t lower the precondition time.
        await (tests / "timeout-again").do(catching: Mongo.TimeoutError.self)
        {
            let _:[Letter] = try await ReadLetters()
        }
        //  We should still be able to read from the locked secondary/slave from
        //  a different session. Because that session’s timeline should have no
        //  relationship with the current session’s timeline, the read should
        //  succeed, and return the stale data from before the last three writes.
        await (tests / "non-causal").do
        {
            let letters:[Letter] = try await other.run(
                command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(
                    collection: collection,
                    limit: 10),
                against: database,
                on: secondary)
            
            guard let time:Mongo.Instant = tests.expect(value: other.preconditionTime)
            else
            {
                return
            }
            //  The data returned should be stale. We should be able to verify
            //  this both from the parallel session’s precondition time, and
            //  the returned data.
            tests.expect(true: time < head)
            tests.expect(letters ..? [a])
        }
        //  We should still receive a timeout error if we try to read from the
        //  locked secondary/slave using a session that was forked from the
        //  current session, however.
        await (tests / "timeout-forked").do(catching: Mongo.TimeoutError.self)
        {
            let forked:Mongo.Session = try await .init(from: pool, forking: session)

            //  A forked session should initially share the same precondition
            //  time as the session it was forked from.
            tests.expect(forked.preconditionTime ==? head)

            let _:[Letter] = try await forked.run(
                command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(
                    collection: collection,
                    limit: 10),
                against: database,
                on: secondary)
        }

        //  We should be able to unlock the secondary/slave.
        lock = try await session.run(command: Mongo.FsyncUnlock.init(),
            against: .admin,
            on: secondary)
        //  We should have unlocked the secondary/slave all the way.
        tests.expect(lock.count ==? 0)

        //  We should be able to read all four writes from the unlocked
        //  secondary/slave, because it has caught up to the session’s
        //  precondition time.
        tests.expect(try await ReadLetters() ..? [a, b, c, d])
    }
}
