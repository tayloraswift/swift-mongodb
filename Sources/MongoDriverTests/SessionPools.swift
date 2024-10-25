import BSON
import MongoDriver
import NIOPosix
import Testing

@Suite struct SessionPools
{
    @Test(arguments: [.standaloneDefault, .replicatedDefault] as [Mongo.DriverBootstrap])
    static func seededOnce(_ bootstrap:Mongo.DriverBootstrap) async throws
    {
        //  These tests ensure we do proper cleanup on all exit paths.
        //  they use no assertions, but should trip sanity checks within
        //  the driver’s `deinit`s if cleanup is not performed correctly.
        try await bootstrap.withSessionPool
        {
            //  Run at least one command to ensure we actually use the session
            let session:Mongo.Session = try await .init(from: $0)
            try await session.refresh()
        }
    }

    @Test(arguments: [.standaloneDefault, .replicatedDefault] as [Mongo.DriverBootstrap])
    static func seededTwice(_ bootstrap:Mongo.DriverBootstrap) async throws
    {
        //  We should be able to initialize a new session pool immediately after
        //  draining the previous one.
        try await bootstrap.withSessionPool
        {
            let session:Mongo.Session = try await .init(from: $0)
            try await session.refresh()
        }
        try await bootstrap.withSessionPool
        {
            let session:Mongo.Session = try await .init(from: $0)
            try await session.refresh()
        }
    }

    @Test(arguments: [.standaloneDefault, .replicatedDefault] as [Mongo.DriverBootstrap])
    static func seededConcurrently(_ bootstrap:Mongo.DriverBootstrap) async throws
    {
        //  We should be able to operate two session pools on the same deployment
        //  at the same time.
        async
        let first:Void = bootstrap.withSessionPool
        {
            let session:Mongo.Session = try await .init(from: $0)
            try await Task.sleep(for: .milliseconds(100))
            try await session.refresh()
        }
        async
        let second:Void = bootstrap.withSessionPool
        {
            let session:Mongo.Session = try await .init(from: $0)
            try await Task.sleep(for: .milliseconds(100))
            try await session.refresh()
        }

        try await first
        try await second
    }

    @Test(arguments: [.standaloneDefault, .replicatedDefault] as [Mongo.DriverBootstrap])
    static func teardownOnError(_ bootstrap:Mongo.DriverBootstrap) async throws
    {
        //  We should be able to tear down a session pool by throwing an error,
        //  even if operations are in progress.

        //  We cannot use #expect here, it crashes the compiler, and sourcekit-lsp :(
        do
        {
            try await bootstrap.withSessionPool
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

    @Test(arguments: [.standaloneDefault, .replicatedDefault] as [Mongo.DriverBootstrap])
    static func overlapping(_ bootstrap:Mongo.DriverBootstrap) async throws
    {
        /// Two overlapping sessions should not re-use the same session.
        try await bootstrap.withSessionPool
        {
            let a:Mongo.Session = try await .init(from: $0)
            let b:Mongo.Session = try await .init(from: $0)

            #expect(await $0.count == 2)

            try await a.refresh()
            try await b.refresh()

            #expect(a.id != b.id)
        }
    }

    @Test(arguments: [.standaloneDefault, .replicatedDefault] as [Mongo.DriverBootstrap])
    static func sessionPools(_ bootstrap:Mongo.DriverBootstrap) async throws
    {
        /// Two forked sessions should not re-use the same session.
        try await bootstrap.withSessionPool
        {
            let a:Mongo.Session = try await .init(from: $0)

            try await a.refresh()

            let b:Mongo.Session = try await a.fork()

            #expect(await $0.count == 2)

            if  case .direct(let list) = bootstrap.seeding, list.count > 1
            {
                #expect(b.preconditionTime != nil)
            }

            try await a.refresh()
            try await b.refresh()

            #expect(a.id != b.id)
        }
    }

    @Test(arguments: [.standaloneDefault, .replicatedDefault] as [Mongo.DriverBootstrap])
    static func nonoverlapping(_ bootstrap:Mongo.DriverBootstrap) async throws
    {
        /// Two non-overlapping sessions should re-use the same session.
        try await bootstrap.withSessionPool
        {
            let id:(Mongo.SessionIdentifier, Mongo.SessionIdentifier)
            do
            {
                let session:Mongo.Session = try await .init(from: $0)
                try await session.refresh()
                #expect(await $0.count == 1)

                id.0 = session.id
            }
            do
            {
                let session:Mongo.Session = try await .init(from: $0)
                try await session.refresh()
                #expect(await $0.count == 1)

                id.1 = session.id
            }

            #expect(id.0 == id.1)
        }
    }

    @Test(arguments: [.standaloneDefault, .replicatedDefault] as [Mongo.DriverBootstrap])
    static func cohorts(_ bootstrap:Mongo.DriverBootstrap) async throws
    {
        /// Session count should never exceed maximum logical width,
        /// even taking into account task execution latencies.
        try await bootstrap.withSessionPool
        {
            for _:Int in 0 ..< 50
            {
                var sessions:[Mongo.Session] = []
                for _:Int in 0 ..< 10
                {
                    sessions.append(try await .init(from: $0))
                }
            }

            #expect(await $0.count == 10)
        }
    }

    @Test(arguments: [.standaloneDefault, .replicatedDefault] as [Mongo.DriverBootstrap])
    static func implicit(_ bootstrap:Mongo.DriverBootstrap) async throws
    {
        /// Serialized usages of implicit sessions should never blow up the pool.
        try await bootstrap.withSessionPool
        {
            let explicit:Mongo.Session = try await .init(from: $0)

            #expect(await $0.count == 1)

            for _:Int in 0 ..< 100
            {
                try await $0.run(
                    command: Mongo.RefreshSessions.init(explicit.id),
                    against: .admin)
            }

            // Make sure we use the explicit session, to prevent it from
            // being deinitialized
            try await explicit.refresh()

            #expect(await $0.count == 2)
        }
    }
}
