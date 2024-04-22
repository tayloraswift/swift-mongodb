import MongoDriver
import NIOPosix
import Testing_

func TestFailpoints(_ tests:TestGroup, bootstrap:Mongo.DriverBootstrap) async
{
    guard let tests:TestGroup = tests / "failpoints"
    else
    {
        return
    }

    await bootstrap.withSessionPool
    {
        (pool:Mongo.SessionPool) in

        await (tests ! "configure").do
        {
            try await pool.run(
                command: Mongo.ConfigureFailpoint<Mongo.FailCommand>.once(.init(
                    behavior: .blockConnection(then: .error(9999)),
                    appname: bootstrap.appname,
                    types: [.ping])),
                against: .admin,
                on: .primary)
        }
        //  We should be able to observe the ping command fail the first
        //  time we try to run it.
        await (tests ! "ping-first").do(catching: Mongo.ServerError.init(9999,
            message: "Failing command via 'failCommand' failpoint"))
        {
            try await pool.run(command: Mongo.Ping.init(),
                against: .admin,
                on: .primary)
        }
        //  We should be able to observe the ping command succeed the second
        //  time we try to run it.
        await (tests ! "ping-second").do
        {
            try await pool.run(command: Mongo.Ping.init(),
                against: .admin,
                on: .primary)
        }
    }
}
