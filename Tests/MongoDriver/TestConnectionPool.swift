import MongoDriver
import NIOPosix
import Testing

func TestConnectionPool(_ tests:inout Tests,
    credentials:Mongo.Credentials?,
    seedlist:Set<Mongo.Host>,
    on executor:MultiThreadedEventLoopGroup) async
{
    let bootstrap:Mongo.DriverBootstrap = .init(
        credentials: credentials,
        executor: executor)
    
    await tests.group("connection-pools")
    {
        //  This test makes 500 connection requests to the primary/master’s connection
        //  pool, and holds the connections (preventing them from being reused) for
        //  half the duration of the test, to force the pool to expand.
        /// The pool should expand to its maximum size (100), and no further.
        await $0.test(name: "oversubscription")
        {
            (tests:inout Tests) in

            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let midpoint:Mongo.ConnectionDeadline = .now.advanced(by: .milliseconds(500))
                let deadline:Mongo.ConnectionDeadline = midpoint.advanced(by: .milliseconds(500))
                try await $0.withDirectConnections(to: .primary, by: midpoint)
                {
                    (pool:Mongo.ConnectionPool) in

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

                    tests.assert(await pool.count ==? 100, name: "pool-count")
                }
            }
        }
        //  This test makes 500 connection requests to the primary/master’s connection
        //  pool in batches of 10 connections at a time. On each iteration, the old
        //  batch should become available for reuse, so the pool should not continue
        //  expanding.
        await $0.test(name: "cohorts")
        {
            (tests:inout Tests) in

            try await bootstrap.withSessionPool(seedlist: seedlist)
            {
                let deadline:Mongo.ConnectionDeadline = .now.advanced(by: .milliseconds(500))
                try await $0.withDirectConnections(to: .primary, by: deadline)
                {
                    (pool:Mongo.ConnectionPool) in

                    for _:Int in 0 ..< 50
                    {
                        var connections:[Mongo.Connection] = []
                        for _:Int in 0 ... 10
                        {
                            connections.append(try await .init(from: pool, by: deadline))
                        }
                    }

                    tests.assert(await 10 ... 20 ~=? pool.count, name: "pool-count")
                }
            }
        }
    }
}
