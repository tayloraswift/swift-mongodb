import MongoDriver
import NIOPosix
import Testing

func TestSessionPool(_ tests:TestGroup,
    credentials:Mongo.Credentials?,
    seedlist:Set<Mongo.Host>,
    on executor:MultiThreadedEventLoopGroup) async
{
    let tests:TestGroup = tests / "session-pools"

    let bootstrap:Mongo.DriverBootstrap = .init(
        credentials: credentials,
        executor: executor)
    do
    {
        let tests:TestGroup = tests / "lifecycles"
        //  these tests ensure we do proper cleanup on all exit paths.
        //  they use no assertions, but should trip sanity checks within
        //  the driver’s `deinit`s if cleanup is not performed correctly.
        await (tests / "seeded-once").do
        {
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                //  run at least one command to ensure we actually use the session
                let session:Mongo.Session = try await .init(from: $0)
                try await session.refresh()
            }
        }
        //  We should be able to initialize a new session pool immediately after
        //  draining the previous one.
        await (tests / "seeded-twice").do
        {
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let session:Mongo.Session = try await .init(from: $0)
                try await session.refresh()
            }
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let session:Mongo.Session = try await .init(from: $0)
                try await session.refresh()
            }
        }
        //  We should be able to operate two session pools on the same deployment
        //  at the same time.
        await (tests / "seeded-concurrently").do
        {
            async
            let first:Void = bootstrap.withSessionPool(seedlist: seedlist)
            {
                let session:Mongo.Session = try await .init(from: $0)
                try await Task.sleep(for: .milliseconds(100))
                try await session.refresh()
            }
            async
            let second:Void = bootstrap.withSessionPool(seedlist: seedlist)
            {
                let session:Mongo.Session = try await .init(from: $0)
                try await Task.sleep(for: .milliseconds(100))
                try await session.refresh()
            }

            try await first
            try await second
        }
        //  We should be able to tear down a session pool by throwing an error,
        //  even if operations are in progress.
        await (tests / "error-pool").do
        {
            do
            {
                try await bootstrap.withSessionPool(seedlist: seedlist)
                {
                    (pool:Mongo.SessionPool) in

                    async
                    let _:Void =
                    {
                        let session:Mongo.Session = try await .init(from: pool)
                        try await session.refresh()
                        try await Task.sleep(for: .milliseconds(100))
                        try await session.refresh()
                    }()
                    try await Task.sleep(for: .milliseconds(50))
                    throw CancellationError.init()
                }
            }
            catch is CancellationError
            {
            }
        }
    }
    do
    {
        let tests:TestGroup = tests / "overlapping"
        /// Two overlapping sessions should not re-use the same session.
        await tests.do
        {
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let a:Mongo.Session = try await .init(from: $0)
                let b:Mongo.Session = try await .init(from: $0)

                tests.expect(await $0.count ==? 2)

                try await a.refresh()
                try await b.refresh()
                
                tests.expect(true: a.id != b.id)
            }
        }
    }
    do
    {
        let tests:TestGroup = tests / "forked"
        /// Two forked sessions should not re-use the same session.
        await tests.do
        {
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let a:Mongo.Session = try await .init(from: $0)

                try await a.refresh()

                let b:Mongo.Session = try await .init(from: $0, forking: a)

                tests.expect(await $0.count ==? 2)

                if seedlist.count > 1
                {
                    let _:Mongo.Instant? = tests.expect(value: b.preconditionTime)
                }

                try await a.refresh()
                try await b.refresh()
                
                tests.expect(true: a.id != b.id)
            }
        }
    }
    do
    {
        let tests:TestGroup = tests / "non-overlapping"
        /// Two non-overlapping sessions should re-use the same session.
        await tests.do
        {
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let id:(Mongo.SessionIdentifier, Mongo.SessionIdentifier)
                do
                {
                    let session:Mongo.Session = try await .init(from: $0)
                    try await session.refresh()
                    tests.expect(await $0.count ==? 1)

                    id.0 = session.id
                }
                do
                {
                    let session:Mongo.Session = try await .init(from: $0)
                    try await session.refresh()
                    tests.expect(await $0.count ==? 1)

                    id.1 = session.id
                }
                tests.expect(id.0 ==? id.1)
            }
        }
    }
    do
    {
        let tests:TestGroup = tests / "cohorts"
        /// Session count should never exceed maximum logical width,
        /// even taking into account task execution latencies.
        await tests.do
        {
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                for _:Int in 0 ..< 50
                {
                    var sessions:[Mongo.Session] = []
                    for _:Int in 0 ..< 10
                    {
                        sessions.append(try await .init(from: $0))
                    }
                }

                tests.expect(await $0.count ==? 10)
            }
        }
    }
    do
    {
        let tests:TestGroup = tests / "implicit"
        /// Serialized usages of implcit sessions should never blow up the pool.
        await tests.do
        {
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let explicit:Mongo.Session = try await .init(from: $0)

                tests.expect(await $0.count ==? 1)

                for _:Int in 0 ..< 100
                {
                    try await $0.run(command: Mongo.RefreshSessions.init(explicit.id),
                        against: .admin)
                }

                // make sure we use the explicit session, to prevent it from
                // being deinitialized
                try await explicit.refresh()

                tests.expect(await $0.count ==? 2)
            }
        }
    }
}
