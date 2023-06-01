import NIOPosix
import MongoDB
import Testing

@main
enum Main:AsyncTests
{
    static
    func run(tests:Tests) async
    {
        let executors:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        if  let tests:TestGroup = tests / "Replicated"
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

            let bootstrap:Mongo.DriverBootstrap = MongoDB / members /?
            {
                $0.executors = .shared(executors)
                $0.connectionTimeout = .milliseconds(1000)
            }

            await bootstrap.run(tests,
                Aggregate.init(),
                Collections.init(),
                Cursors.init(servers: [
                    .primary,
                    //  We should be able to run this test on a specific server.
                    .nearest(tagSets: [["name": "B"]]),
                    //  We should be able to run this test on a secondary.
                    .nearest(tagSets: [["name": "C"]]),
                ]),
                Databases.init(),
                Delete.init(),
                Find.init(),
                FindAndModify.init(),
                Fsync.init(),
                Indexes.init(),
                Insert.init(),
                Transactions.init(),
                Update.init())

            let slow:Mongo.DriverBootstrap = MongoDB / members /?
            {
                $0.executors = .shared(executors)
                $0.connectionTimeout = .milliseconds(2000)
            }

            await slow.run(tests, CausalConsistency.init())
        }

        if  let tests:TestGroup = tests / "Single"
        {
            let seedlist:Mongo.Seedlist = ["mongo-single": 27017]
            let bootstrap:Mongo.DriverBootstrap = MongoDB / ("root", "80085") * seedlist /?
            {
                $0.authentication = .sasl(.sha256)
                $0.executors = .shared(executors)
            }

            await bootstrap.run(tests,
                Aggregate.init(),
                Collections.init(),
                Cursors.init(servers: [.primary]),
                Databases.init(),
                Delete.init(),
                Find.init(),
                FindAndModify.init(),
                Fsync.init(),
                Indexes.init(),
                Insert.init(),
                Update.init())
        }
    }
}
