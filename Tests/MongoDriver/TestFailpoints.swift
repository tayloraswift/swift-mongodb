import MongoDriver
import NIOPosix
import Testing

func TestFailpoints(_ tests:TestGroup,
    credentials:Mongo.Credentials?,
    seedlist:Set<Mongo.Host>,
    on executor:MultiThreadedEventLoopGroup) async
{
    let application:String = "swift-mongodb-tests"
    let bootstrap:Mongo.DriverBootstrap = .init(application: application,
        credentials: credentials,
        executor: executor)
    
    let tests:TestGroup = tests / "failpoints"

    await bootstrap.withSessionPool(seedlist: seedlist)
    {
        (pool:Mongo.SessionPool) in

        await (tests / "configure").do
        {
            try await pool.run(
                command: Mongo.ConfigureFailpoint<Mongo.FailCommand>.once(.init(
                    application: application,
                    behavior: .blockConnection(then: .error(9999)),
                    types: [Mongo.Ping.self])),
                against: .admin,
                on: .primary)
        }
        //  We should be able to observe the ping command fail the first
        //  time we try to run it.
        await (tests / "ping-first").do(catching: Mongo.ServerError.init(9999,
            message: "Failing command via 'failCommand' failpoint"))
        {
            try await pool.run(command: Mongo.Ping.init(),
                against: .admin,
                on: .primary)
        }
        //  We should be able to observe the ping command succeed the second
        //  time we try to run it.
        await (tests / "ping-second").do
        {
            try await pool.run(command: Mongo.Ping.init(),
                against: .admin,
                on: .primary)
        }
    }
}
