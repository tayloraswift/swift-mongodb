import MongoDriver
import NIOPosix
import Testing

func TestSessionPool(_ tests:inout Tests,
    credentials:Mongo.Credentials?,
    seedlist:Set<Mongo.Host>,
    on executor:MultiThreadedEventLoopGroup) async
{
    let bootstrap:Mongo.DriverBootstrap = .init(
        credentials: credentials,
        executor: executor)
    
    await tests.group("session-pool-lifecycles")
    {
        //  these tests ensure we do proper cleanup on all exit paths.
        //  they use no assertions, but should trip sanity checks within
        //  the driver’s `deinit`s if cleanup is not performed correctly.
        await $0.test(name: "seeded-once")
        {
            _ in
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                //  run at least one command to ensure we actually use the session
                let session:Mongo.Session = try await .init(from: $0)
                try await session.refresh()
            }
        }
        //  We should be able to initialize a new session pool immediately after
        //  draining the previous one.
        await $0.test(name: "seeded-twice")
        {
            _ in
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
        await $0.test(name: "seeded-concurrently")
        {
            _ in
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
        await $0.test(name: "error-pool")
        {
            _ in
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
    await tests.group("session-pools")
    {
        /// Two overlapping sessions should not re-use the same session.
        await $0.test(name: "overlapping")
        {
            (tests:inout Tests) in

            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let a:Mongo.Session = try await .init(from: $0)
                let b:Mongo.Session = try await .init(from: $0)

                tests.assert(await $0.count ==? 2, name: "pool-count")

                try await a.refresh()
                try await b.refresh()
                
                tests.assert(a.id != b.id, name: "identifiers-not-equal")
            }
        }
        /// Two non-overlapping sessions should re-use the same session.
        await $0.test(name: "non-overlapping")
        {
            (tests:inout Tests) in

            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let id:(Mongo.SessionIdentifier, Mongo.SessionIdentifier)
                do
                {
                    let session:Mongo.Session = try await .init(from: $0)
                    try await session.refresh()
                    tests.assert(await $0.count ==? 1, name: "pool-count-first")

                    id.0 = session.id
                }
                do
                {
                    let session:Mongo.Session = try await .init(from: $0)
                    try await session.refresh()
                    tests.assert(await $0.count ==? 1, name: "pool-count-second")

                    id.1 = session.id
                }
                tests.assert(id.0 ==? id.1, name: "identifiers-equal")
            }
        }
        /// Session count should never exceed maximum logical width,
        /// even taking into account task execution latencies.
        await $0.test(name: "cohorts")
        {
            (tests:inout Tests) in

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

                tests.assert(await $0.count ==? 10, name: "pool-count")
            }
        }
        /// Serialized usages of implcit sessions should never blow up the pool.
        await $0.test(name: "implicit")
        {
            (tests:inout Tests) in

            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let explicit:Mongo.Session = try await .init(from: $0)

                tests.assert(await $0.count ==? 1, name: "pool-count-before")

                for _:Int in 0 ..< 100
                {
                    try await $0.run(command: Mongo.RefreshSessions.init(explicit.id),
                        against: .admin)
                }

                // make sure we use the explicit session, to prevent it from
                // being deinitialized
                try await explicit.refresh()

                tests.assert(await $0.count ==? 2, name: "pool-count-after")
            }
        }
    }
}
