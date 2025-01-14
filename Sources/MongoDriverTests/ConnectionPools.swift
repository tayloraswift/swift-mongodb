import MongoConfiguration
@_spi(testable) import MongoDriver
import NIOPosix
import Testing

@Suite struct ConnectionPools
{
    private static
    var matrix:[Mongo.DriverBootstrap]
    {
        [
            //  No preconnections
            .replicatedDefault,
            .standaloneDefault,

            //  Preconnections
            mongodb / .replicated /?
            {
                $0.connectionTimeout = .milliseconds(2000)
                $0.connectionPoolSize = 2 ... 50
                $0.executors = MultiThreadedEventLoopGroup.singleton
            },
            mongodb / .standalone /?
            {
                $0.connectionTimeout = .milliseconds(2000)
                $0.connectionPoolSize = 2 ... 50
                $0.executors = MultiThreadedEventLoopGroup.singleton
            },

            //  Preconnections (small)
            mongodb / .replicated /?
            {
                $0.connectionTimeout = .milliseconds(2000)
                $0.connectionPoolSize = 0 ... 10
                $0.executors = MultiThreadedEventLoopGroup.singleton
            },
            mongodb / .standalone /?
            {
                $0.connectionTimeout = .milliseconds(2000)
                $0.connectionPoolSize = 0 ... 10
                $0.executors = MultiThreadedEventLoopGroup.singleton
            },
        ]
    }

    //  This test makes 500 connection requests to the primary/master’s connection
    //  pool, and holds the connections (preventing them from being reused) for
    //  half the duration of the test, to force the pool to expand.
    //  The pool should expand to its maximum size, and no further.
    @Test(arguments: Self.matrix)
    static func oversubscription(_ bootstrap:Mongo.DriverBootstrap) async throws
    {
        try await bootstrap.withSessionPool
        {
            let midpoint:ContinuousClock.Instant = .now.advanced(
                by: .milliseconds(500))
            let deadline:ContinuousClock.Instant = midpoint.advanced(
                by: .milliseconds(500))

            let pool:Mongo.ConnectionPool = try await $0.connect(to: .primary,
                by: midpoint)

            try await withThrowingTaskGroup(of: Void.self)
            {
                (tasks:inout ThrowingTaskGroup<Void, any Error>) in

                for _:Int in 0 ..< 500
                {
                    tasks.addTask
                    {
                        let connection:Mongo.Connection = try await .init(from: pool,
                            by: deadline)
                        try await Task.sleep(until: midpoint,
                                clock: .continuous)
                        withExtendedLifetime(connection)
                        {
                        }
                    }
                }
                for try await _:Void in tasks
                {
                }
            }

            #expect(await pool.count == bootstrap.connectionPoolSize.upperBound)
        }
    }

    //  This test makes 500 connection requests to the primary/master’s connection
    //  pool in batches of 10 connections at a time. On each iteration, the old
    //  batch should become available for reuse, so the pool should not continue
    //  expanding.
    @Test(arguments: Self.matrix)
    static func cohorts(_ bootstrap:Mongo.DriverBootstrap) async throws
    {
        try await bootstrap.withSessionPool
        {
            let deadline:ContinuousClock.Instant = .now.advanced(by: .milliseconds(500))
            let pool:Mongo.ConnectionPool = try await $0.connect(to: .primary,
                by: deadline)
            for _:Int in 0 ..< 50
            {
                var connections:[Mongo.Connection] = []
                for _:Int in 0 ..< 10
                {
                    connections.append(try await .init(from: pool, by: deadline))
                }
            }

            #expect(await pool.count == 10)
        }
    }

    @Test(arguments: Self.matrix)
    static func perishment(_ bootstrap:Mongo.DriverBootstrap) async throws
    {
        try await bootstrap.withSessionPool
        {
            let deadline:ContinuousClock.Instant = .now.advanced(by: .milliseconds(3000))
            let pool:Mongo.ConnectionPool = try await $0.connect(to: .primary,
                by: deadline)
            //  Use up the pool’s entire capacity by hoarding connections.
            var connections:[Mongo.Connection] = []

            for _:Int in 0 ..< bootstrap.connectionPoolSize.upperBound
            {
                connections.append(try await .init(from: pool, by: deadline))
            }

            #expect(await pool.count == bootstrap.connectionPoolSize.upperBound)

            //  Interrupt ten of those connections.
            for connection:Mongo.Connection in connections.prefix(10)
            {
                connection.crosscancel(throwing: CancellationError.init())
            }
            //  Even though we haven’t returned the perished connections
            //  to the pool, it should still be able to re-create ten
            //  connections to replace them.
            for _:Int in 0 ..< 10
            {
                connections.append(try await .init(from: pool, by: deadline))
            }
        }
    }
}
