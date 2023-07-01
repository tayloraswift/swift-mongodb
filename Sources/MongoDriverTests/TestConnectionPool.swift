import MongoDriver
import NIOPosix
import Testing

func TestConnectionPool(_ tests:TestGroup,
    matrix:KeyValuePairs<String, Mongo.DriverBootstrap>) async
{
    for (name, bootstrap):(String, Mongo.DriverBootstrap) in matrix
    {
        if  let tests:TestGroup = tests / "connection-pools" / name
        {
            await TestConnectionPool(tests, bootstrap: bootstrap)
        }
    }
}
func TestConnectionPool(_ tests:TestGroup, bootstrap:Mongo.DriverBootstrap) async
{
    //  This test makes 500 connection requests to the primary/master’s connection
    //  pool, and holds the connections (preventing them from being reused) for
    //  half the duration of the test, to force the pool to expand.
    //  The pool should expand to its maximum size, and no further.
    if  let tests:TestGroup = tests / "oversubscription"
    {
        await tests.do
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

                tests.expect(await pool.count ==? bootstrap.connectionPoolSize.upperBound)
            }
        }
    }
    //  This test makes 500 connection requests to the primary/master’s connection
    //  pool in batches of 10 connections at a time. On each iteration, the old
    //  batch should become available for reuse, so the pool should not continue
    //  expanding.
    if  let tests:TestGroup = tests / "cohorts"
    {
        await tests.do
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

                tests.expect(await pool.count ==? 10)
            }
        }
    }
    if  let tests:TestGroup = tests / "perishment"
    {
        await tests.do
        {
            try await bootstrap.withSessionPool
            {
                let deadline:ContinuousClock.Instant = .now.advanced(by: .milliseconds(3000))
                let pool:Mongo.ConnectionPool = try await $0.connect(to: .primary,
                    by: deadline)
                //  use up the pool’s entire capacity by hoarding connections.
                var connections:[Mongo.Connection] = []

                await (tests ! "before").do
                {
                    for _:Int in 0 ..< bootstrap.connectionPoolSize.upperBound
                    {
                        connections.append(try await .init(from: pool, by: deadline))
                    }
                }

                tests.expect(await pool.count ==? bootstrap.connectionPoolSize.upperBound)

                //  interrupt ten of those connections.
                for connection:Mongo.Connection in connections.prefix(10)
                {
                    connection.crosscancel(throwing: CancellationError.init())
                }
                //  even though we haven’t returned the perished connections
                //  to the pool, it should still be able to re-create ten
                //  connections to replace them.
                await (tests ! "after").do
                {
                    for _:Int in 0 ..< 10
                    {
                        connections.append(try await .init(from: pool, by: deadline))
                    }
                }
            }
        }
    }
}
