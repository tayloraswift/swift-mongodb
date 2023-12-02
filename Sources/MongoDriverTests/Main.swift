import MongoConfiguration
import MongoDriver
import NIOPosix
import Testing

var mongodb:Mongo.URI.Base<Mongo.Guest, Mongo.DirectSeeding>
{
    .init(userinfo: .init())
}

@main
enum Main:TestMain, TestBattery
{
    static
    func run(tests:TestGroup) async
    {
        let executors:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
        if  let tests:TestGroup = tests / "replicated"
        {
            let members:Mongo.Seedlist =
            [
                "mongo-0": 27017,
                "mongo-1": 27017,
                "mongo-2": 27017,
                "mongo-3": 27017,
                "mongo-4": 27017,
                "mongo-5": 27017,
                "mongo-6": 27017,
            ]

            print("running tests for replicated topology (hosts: \(members))")

            let bootstrap:Mongo.DriverBootstrap = mongodb / members /?
            {
                $0.connectionTimeout = .milliseconds(2000)
                $0.executors = .shared(executors)
                $0.appname = "MongoDriverTests"
            }

            await TestFailpoints(tests, bootstrap: bootstrap)

            await TestSessionPool(tests, bootstrap: bootstrap)

            await TestConnectionPool(tests, matrix:
            [
                "default": bootstrap,

                "preconnecting": mongodb / members /?
                {
                    $0.connectionTimeout = .milliseconds(2000)
                    $0.connectionPoolSize = 2 ... 50
                    $0.executors = .shared(executors)
                },

                "small": mongodb / members /?
                {
                    $0.connectionTimeout = .milliseconds(2000)
                    $0.connectionPoolSize = 0 ... 10
                    $0.executors = .shared(executors)
                },
            ])

            await TestMemberDiscovery(tests, members: members, matrix:
            [
                "from-0": mongodb / members(0 ... 0) /?
                {
                    $0.executors = .shared(executors)
                },
                "from-1": mongodb / members(1 ... 1) /?
                {
                    $0.executors = .shared(executors)
                },
                "from-2": mongodb / members(2 ... 2) /?
                {
                    $0.executors = .shared(executors)
                },
                "from-3": mongodb / members(3 ... 3) /?
                {
                    $0.executors = .shared(executors)
                },
                "from-4": mongodb / members(4 ... 4) /?
                {
                    $0.executors = .shared(executors)
                },
                "from-5": mongodb / members(5 ... 5) /?
                {
                    $0.executors = .shared(executors)
                },
                "from-6": mongodb / members(6 ... 6) /?
                {
                    $0.executors = .shared(executors)
                },
            ])
            await TestReadPreference(tests, members: members, bootstrap: mongodb / members /?
            {
                $0.connectionTimeout = .milliseconds(250)
                $0.executors = .shared(executors)
            })
        }

        if  let tests:TestGroup = tests / "single"
        {
            let seedlist:Mongo.Seedlist = ["mongo-single": 27017]

            print("running tests for single topology (host: \(seedlist))")

            let username:String = "root",
                password:String = "80085"

            await TestAuthentication(tests,
                executors: executors,
                seedlist: seedlist,
                username: username,
                password: password)

            let bootstrap:Mongo.DriverBootstrap = mongodb / (username, password) * seedlist /?
            {
                $0.executors = .shared(executors)
            }
            await TestFailpoints(tests, bootstrap: bootstrap)

            await TestSessionPool(tests, bootstrap: bootstrap, single: true)

            await TestConnectionPool(tests, matrix:
            [
                "default": bootstrap,

                "preconnecting": mongodb / seedlist /?
                {
                    $0.connectionTimeout = .milliseconds(2000)
                    $0.connectionPoolSize = 2 ... 50
                    $0.executors = .shared(executors)
                },

                "small": mongodb / seedlist /?
                {
                    $0.connectionTimeout = .milliseconds(2000)
                    $0.connectionPoolSize = 0 ... 10
                    $0.executors = .shared(executors)
                },
            ])
        }
    }
}
