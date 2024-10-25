import MongoDriver
import NIOPosix
import Testing

@Suite
struct Failpoints
{
    @Test(arguments: [.standaloneDefault, .replicatedDefault] as [Mongo.DriverBootstrap])
    static func failpoints(_ bootstrap:Mongo.DriverBootstrap) async throws
    {
        try await bootstrap.withSessionPool
        {
            (pool:Mongo.SessionPool) in

            try await pool.run(
                command: Mongo.ConfigureFailpoint<Mongo.FailCommand>.once(.init(
                    behavior: .blockConnection(then: .error(9999)),
                    appname: bootstrap.appname,
                    types: [.ping])),
                against: .admin,
                on: .primary)

            //  We should be able to observe the ping command fail the first
            //  time we try to run it.
            await #expect(throws: Mongo.ServerError.init(9999,
                message: "Failing command via 'failCommand' failpoint"))
            {
                try await pool.run(command: Mongo.Ping.init(),
                    against: .admin,
                    on: .primary)
            }
            //  We should be able to observe the ping command succeed the second
            //  time we try to run it.
            try await pool.run(command: Mongo.Ping.init(),
                against: .admin,
                on: .primary)
        }
    }
}
