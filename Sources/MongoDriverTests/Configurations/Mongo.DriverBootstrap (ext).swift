import MongoConfiguration
import MongoDriver
import NIOPosix

extension Mongo.DriverBootstrap
{
    static var standaloneDefault:Self
    {
        mongodb / Authentication.login * .standalone /?
        {
            $0.executors = MultiThreadedEventLoopGroup.singleton
        }
    }

    static var replicatedDefault:Self
    {
        mongodb / .replicated /?
        {
            $0.connectionTimeout = .milliseconds(2000)
            $0.executors = MultiThreadedEventLoopGroup.singleton
            $0.appname = "MongoDriverTests"
        }
    }
}
