import MongoDriver
import NIOPosix
import Testing

func TestConnectionPool(_ tests:TestGroup,
    credentials:Mongo.Credentials?,
    seedlist:Set<Mongo.Host>,
    on executor:MultiThreadedEventLoopGroup) async
{
    let bootstrap:Mongo.DriverBootstrap = .init(
        credentials: credentials,
        executor: executor)
    
    let tests:TestGroup = tests / "connection-pools"
    //  This test makes 500 connection requests to the primary/master’s connection
    //  pool, and holds the connections (preventing them from being reused) for
    //  half the duration of the test, to force the pool to expand.
    /// The pool should expand to its maximum size (100), and no further.
    do
    {
        let tests:TestGroup = tests / "oversubscription"
        await tests.do
        {
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let midpoint:Mongo.ConnectionDeadline = .now.advanced(
                    by: .milliseconds(500))
                let deadline:Mongo.ConnectionDeadline = midpoint.advanced(
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
                            try await Task.sleep(until: midpoint.instant,
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

                tests.expect(await pool.count ==? 100)
            }
        }
    }
    //  This test makes 500 connection requests to the primary/master’s connection
    //  pool in batches of 10 connections at a time. On each iteration, the old
    //  batch should become available for reuse, so the pool should not continue
    //  expanding.
    do
    {
        let tests:TestGroup = tests / "cohorts"
        await tests.do
        {
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let deadline:Mongo.ConnectionDeadline = .now.advanced(by: .milliseconds(500))
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
    do
    {
        let tests:TestGroup = tests / "perishment"
        await tests.do
        {
            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let deadline:Mongo.ConnectionDeadline = .now.advanced(by: .milliseconds(1000))
                let pool:Mongo.ConnectionPool = try await $0.connect(to: .primary,
                    by: deadline)
                //  use up the pool’s entire capacity by hoarding connections.
                var connections:[Mongo.Connection] = []
                for _:Int in 0 ..< 100
                {
                    connections.append(try await .init(from: pool, by: deadline))
                }

                tests.expect(await pool.count ==? 100)

                //  interrupt ten of those connections.
                for connection:Mongo.Connection in connections.prefix(10)
                {
                    connection.interrupt()
                }
                //  even though we haven’t returned the perished connections
                //  to the pool, it should still be able to re-create ten
                //  connections to replace them.
                for _:Int in 0 ..< 10
                {
                    connections.append(try await .init(from: pool, by: deadline))
                }
            }
        }
    }
}
