import BSON
import MongoDB
import Testing

/// This test cannot run concurrently with any other test suites! This is because it modifies
/// the deployment itself, and expects the deployment to be in specific states at specific
/// times.
@Suite
struct CausalConsistency:Mongo.TestBattery
{
    let database:Mongo.Database = "CausalConsistency"
    var logging:Mongo.LogSeverity { .debug }

    //  This test only makes sense in a replicated topology.
    @Test(arguments: [.replicatedWithLongerTimeout] as [any Mongo.TestConfiguration])
    func causalConsistency(_ configuration:any Mongo.TestConfiguration) async throws
    {
        try await self.run(under: configuration)
    }

    func run(with pool:Mongo.SessionPool) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)

        let collection:Mongo.Collection = "Letters"
        let a:Letter = "a"
        let b:Letter = "b"
        let c:Letter = "c"
        let d:Letter = "d"

        //  A new session should have no precondition time.
        #expect(nil == session.preconditionTime)

        //  We should have a test deployment with seven members, including one
        //  arbiter, one (non-voting) hidden replica, and five visible
        //  replicas.
        //
        //  Therefore, writes must propogate to at least three replicas
        //  (besides the hidden replica) to pass a `majority` write concern.
        do
        {
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(collection,
                    writeConcern: .acknowledged(by: 5, journaled: true),
                    encoding: [a]),
                    //  We should ensure the write propogates to all five visible replicas.
                against: self.database,
                on: .primary)

            #expect(response == .init(inserted: 1))
        }

        let other:Mongo.Session = try await session.fork()

        //  We should be able to observe a precondition time after performing the
        //  initialization.
        var head:BSON.Timestamp = try #require(session.preconditionTime)

        //  We should be able to choose this specific slave, which we know will
        //  always be a slave, because it is not a citizen. It was configured
        //  with zero votes, so no other secondaries should be replicating from it.
        let secondary:Mongo.ReadPreference = .secondary(
            tagSets: [["priority": "zero", "name": "E"]])

        //  We should be able to lock this slave, without removing it from quorum.
        //  Until this slave is unlocked, writes must propogate to all three of
        //  the other (non-hidden) replicas to pass a `majority` write concern.
        var lock:Mongo.FsyncLock = try await session.run(
            command: Mongo.Fsync.init(lock: true),
            against: .admin,
            on: secondary)

        #expect(lock.count == 1)

        //  We should be able to fix the test deployment if a previous run
        //  of this test got interrupted.
        for count:Int in (1 ..< lock.count).reversed()
        {
            lock = try await session.run(command: Mongo.FsyncUnlock.init(),
                against: .admin,
                on: secondary)

            #expect(lock.count == count)
        }

        //  We should be able to read the `a`, because this slave acknowledged
        //  the write that added it to the collection before we locked it.
        do
        {
            let letters:[Letter] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                    limit: 10),
                against: self.database,
                on: secondary)

            #expect(letters == [a])
        }
        //  We should be able to insert a letter `b` into the collection (on
        //  the master), using a majority write concern. We should succeed
        //  because there are still three unlocked members able to acknowledge
        //  the write.
        do
        {
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(collection,
                    writeConcern: .majority(journaled: true),
                    encoding: [b]),
                against: self.database,
                on: .primary)

            #expect(response == .init(inserted: 1))
        }

        //  We should still be able to observe a precondition time, and the
        //  value of that time should be greater than it was before we inserted
        //  the letter `b` into the collection.
        do
        {
            let time:BSON.Timestamp = try #require(session.preconditionTime)

            #expect(head < time)

            head = time
        }

        //  We should be able to insert a letter `c` into the collection (on
        //  the master), using an acknowledgement count write concern.
        //  We should succeed because three acknowledgements is currently the
        //  threshold needed to pass a majority write concern.
        do
        {
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(collection,
                    writeConcern: .acknowledged(by: 3, journaled: true),
                    encoding: [c]),
                against: self.database,
                on: .primary)

            #expect(response == .init(inserted: 1))
        }

        do
        {
            let time:BSON.Timestamp = try #require(session.preconditionTime)

            #expect(head < time)

            head = time
        }

        //  We should be able to insert a letter `d` into the collection (on the
        //  master), using an acknowledgement count write concern that is lower
        //  than the current majority threshold. We should succeed because this
        //  insertion should also have been able to pass a majority write concern.
        do
        {
            let response:Mongo.InsertResponse = try await session.run(
                command: Mongo.Insert.init(collection,
                    writeConcern: .acknowledged(by: 2, journaled: true),
                    encoding: [d]),
                against: self.database,
                on: .primary)

            #expect(response == .init(inserted: 1))
        }

        do
        {
            let time:BSON.Timestamp = try #require(session.preconditionTime)

            #expect(head < time)

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
                command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                    limit: 10)
                {
                    $0[.sort, using: Letter.CodingKey.self]
                    {
                        $0[.id] = (+)
                    }
                },
                against: self.database,
                on: secondary,
                by: .now.advanced(by: .milliseconds(500)))
        }

        //  We should receive a timeout error if we try to read from the locked
        //  slave from the current session, because sessions are causally-consistent.
        //
        //  When we used the session to write to the master, we should have updated
        //  the session’s precondition time to the operation time reported by the
        //  master. When we try to read from the locked slave, we should be asking it
        //  for data from a time in its future that it doesn’t have. We should have
        //  prevented it from getting the new data by locking it earlier.
        await #expect(throws: AnyTimeoutError.self)
        {
            do
            {
                let _:[Letter] = try await ReadLetters()
            }
            catch let error
            {
                throw AnyTimeoutError.init(error) ?? error
            }
        }

        //  We should be able to read all four writes from a different,
        //  unlocked slave.
        do
        {
            let letters:[Letter] = try await session.run(
                command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                    limit: 10)
                {
                    $0[.sort, using: Letter.CodingKey.self]
                    {
                        $0[.id] = (+)
                    }
                },
                against: self.database,
                on: .secondary(tagSets: [["name": "D"]]))

            #expect(letters == [a, b, c, d])
        }

        //  We should still receive a timeout error if we try to read from the
        //  locked slave from the current session, because running the last
        //  command didn’t lower the precondition time.
        await #expect(throws: AnyTimeoutError.self)
        {
            do
            {
                let _:[Letter] = try await ReadLetters()
            }
            catch let error
            {
                throw AnyTimeoutError.init(error) ?? error
            }
        }
        //  We should still be able to read from the locked slave from a
        //  different session. Because that session’s timeline should have no
        //  relationship with the current session’s timeline, the read should
        //  succeed, and return the stale data from before the last three writes.
        do
        {
            let letters:[Letter] = try await other.run(
                command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                    limit: 10),
                against: self.database,
                on: secondary)

            let time:BSON.Timestamp = try #require(other.preconditionTime)
            //  The data returned should be stale. We should be able to verify
            //  this both from the parallel session’s precondition time, and
            //  the returned data.
            #expect(time < head)
            #expect(letters == [a])
        }
        //  We should still receive a timeout error if we try to read from the
        //  locked slave using a session that was forked from the current
        //  session, however.
        await #expect(throws: AnyTimeoutError.self)
        {
            let forked:Mongo.Session = try await session.fork()

            //  A forked session should initially share the same precondition
            //  time as the session it was forked from.
            #expect(forked.preconditionTime == head)

            do
            {
                let _:[Letter] = try await forked.run(
                    command: Mongo.Find<Mongo.SingleBatch<Letter>>.init(collection,
                        limit: 10),
                    against: self.database,
                    on: secondary)
            }
            catch let error
            {
                throw AnyTimeoutError.init(error) ?? error
            }
        }

        //  We should be able to unlock the slave.
        lock = try await session.run(command: Mongo.FsyncUnlock.init(),
            against: .admin,
            on: secondary)

        //  We should have unlocked the slave all the way.
        #expect(lock.count == 0)

        //  We should be able to read all four writes from the unlocked slave,
        //  because it has caught up to the session’s precondition time.
        #expect(try await ReadLetters() == [a, b, c, d])
    }
}
