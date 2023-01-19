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
                try await $0.withSession
                {
                    //  run at least one command to ensure we actually use the session
                    try await $0.refresh()
                }
            }
        }
        //  We should be able to initialize a new session pool immediately after
        //  draining the previous one.
        await $0.test(name: "seeded-twice")
        {
            _ in
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                try await $0.withSession
                {
                    try await $0.refresh()
                }
            }
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                try await $0.withSession
                {
                    try await $0.refresh()
                }
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
                try await $0.withSession
                {
                    try await Task.sleep(for: .milliseconds(100))
                    try await $0.refresh()
                }
            }
            async
            let second:Void = bootstrap.withSessionPool(seedlist: seedlist)
            {
                try await $0.withSession
                {
                    try await Task.sleep(for: .milliseconds(100))
                    try await $0.refresh()
                }
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
                    async
                    let _:Void = $0.withSession
                    {
                        try await $0.refresh()
                        try await Task.sleep(for: .milliseconds(100))
                        try await $0.refresh()
                    }
                    try await Task.sleep(for: .milliseconds(50))
                    throw CancellationError.init()
                }
            }
            catch is CancellationError
            {
            }
        }
        //  We should be able to throw an error from inside a session context,
        //  without disturbing other sessions, or the pool as a whole.
        await $0.test(name: "error-session")
        {
            _ in
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                async
                let succeeding:Void = $0.withSession
                {
                    try await Task.sleep(for: .milliseconds(100))
                    try await $0.refresh()
                }
                async
                let failing:Void = $0.withSession
                {
                    _ in throw CancellationError.init()
                }

                try await succeeding
                do
                {
                    try await failing
                }
                catch is CancellationError
                {
                }
            }
        }
    }
    await tests.group("session-pools")
    {
        /// Two non-overlapping sessions should re-use the same session.
        await $0.test(name: "non-overlapping")
        {
            (tests:inout Tests) in

            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let id:(Mongo.SessionIdentifier, Mongo.SessionIdentifier)

                id.0 = try await $0.withSession
                {
                    try await $0.refresh()
                    return $0.id
                }
                id.1 = try await $0.withSession
                {
                    try await $0.refresh()
                    return $0.id
                }

                tests.assert(id.0 ==? id.1, name: "identifiers-equal")
            }
        }
        /// Two overlapping sessions should not re-use the same session.
        await $0.test(name: "overlapping")
        {
            (tests:inout Tests) in

            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                (pool:Mongo.SessionPool) in 

                let id:(Mongo.SessionIdentifier, Mongo.SessionIdentifier) =
                    try await pool.withSession
                {
                    try await $0.refresh()

                    let id:Mongo.SessionIdentifier = try await pool.withSession
                    {
                        try await $0.refresh()
                        return $0.id
                    }
                    return ($0.id, id)
                }

                tests.assert(id.0 != id.1, name: "identifiers-not-equal")
            }
        }
    }
}
