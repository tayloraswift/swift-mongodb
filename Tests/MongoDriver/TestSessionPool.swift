import MongoTopology
import MongoDriver
import NIOPosix
import Testing

func TestSessionPool(_ tests:inout Tests,
    credentials:Mongo.Credentials?,
    seedlist:Set<MongoTopology.Host>,
    on executor:MultiThreadedEventLoopGroup) async
{
    await tests.group("lifecycles")
    {
        //  these tests ensure we do proper cleanup on all exit paths.
        //  they use no assertions, but should trip sanity checks within
        //  the driver’s `deinit`s if cleanup is not performed correctly.
        await $0.test(with: DriverEnvironment.init(name: "seeded-once",
            credentials: credentials,
            executor: executor))
        {
            try await $1.withSessionPool(seedlist: seedlist)
            {
                try await $0.withSession
                {
                    //  run at least one command to ensure we actually use the session
                    try await $0.run(command: Mongo.RefreshSessions.init($0.id))
                }
            }
        }
        //  We should be able to initialize a new session pool immediately after
        //  draining the previous one.
        await $0.test(with: DriverEnvironment.init(name: "seeded-twice",
            credentials: credentials, executor: executor))
        {
            try await $1.withSessionPool(seedlist: seedlist)
            {
                try await $0.withSession
                {
                    try await $0.run(command: Mongo.RefreshSessions.init($0.id))
                }
            }
            try await $1.withSessionPool(seedlist: seedlist)
            {
                try await $0.withSession
                {
                    try await $0.run(command: Mongo.RefreshSessions.init($0.id))
                }
            }
        }
        //  We should be able to operate two session pools on the same deployment
        //  at the same time.
        await $0.test(with: DriverEnvironment.init(name: "seeded-concurrently",
            credentials: credentials, executor: executor))
        {
            async
            let first:Void = $1.withSessionPool(seedlist: seedlist)
            {
                try await $0.withSession
                {
                    try await Task.sleep(for: .milliseconds(100))
                    try await $0.run(command: Mongo.RefreshSessions.init($0.id))
                }
            }
            async
            let second:Void = $1.withSessionPool(seedlist: seedlist)
            {
                try await $0.withSession
                {
                    try await Task.sleep(for: .milliseconds(100))
                    try await $0.run(command: Mongo.RefreshSessions.init($0.id))
                }
            }

            try await first
            try await second
        }
        //  We should be able to tear down a session pool by throwing an error,
        //  even if operations are in progress.
        await $0.test(with: DriverEnvironment.init(name: "error-pool",
            credentials: credentials, executor: executor))
        {
            do
            {
                try await $1.withSessionPool(seedlist: seedlist)
                {
                    async
                    let _:Void = $0.withSession
                    {
                        try await $0.run(command: Mongo.RefreshSessions.init($0.id))
                        try await Task.sleep(for: .milliseconds(100))
                        try await $0.run(command: Mongo.RefreshSessions.init($0.id))
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
        await $0.test(with: DriverEnvironment.init(name: "error-session",
            credentials: credentials, executor: executor))
        {
            try await $1.withSessionPool(seedlist: seedlist)
            {
                async
                let succeeding:Void = $0.withSession
                {
                    try await Task.sleep(for: .milliseconds(100))
                    try await $0.run(command: Mongo.RefreshSessions.init($0.id))
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
    await tests.group("sessions")
    {
        /// Two non-overlapping sessions should re-use the same session.
        await $0.test(with: DriverEnvironment.init(name: "non-overlapping",
            credentials: credentials, executor: executor))
        {
            (tests:inout Tests, bootstrap:Mongo.DriverBootstrap) in

            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let id:(Mongo.SessionIdentifier, Mongo.SessionIdentifier)

                id.0 = try await $0.withSession
                {
                    try await $0.run(command: Mongo.RefreshSessions.init($0.id))
                    return $0.id
                }
                id.1 = try await $0.withSession
                {
                    try await $0.run(command: Mongo.RefreshSessions.init($0.id))
                    return $0.id
                }

                tests.assert(id.0 ==? id.1, name: "identifiers-equal")
            }
        }
        /// Two overlapping sessions should not re-use the same session.
        await $0.test(with: DriverEnvironment.init(name: "overlapping",
            credentials: credentials, executor: executor))
        {
            (tests:inout Tests, bootstrap:Mongo.DriverBootstrap) in

            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                (pool:Mongo.SessionPool) in 

                let id:(Mongo.SessionIdentifier, Mongo.SessionIdentifier) =
                    try await pool.withSession
                {
                    try await $0.run(command: Mongo.RefreshSessions.init($0.id))

                    let id:Mongo.SessionIdentifier = try await pool.withSession
                    {
                        try await $0.run(command: Mongo.RefreshSessions.init($0.id))
                        return $0.id
                    }
                    return ($0.id, id)
                }

                tests.assert(id.0 != id.1, name: "identifiers-not-equal")
            }
        }
    }
}
