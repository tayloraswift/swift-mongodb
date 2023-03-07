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

            let bootstrap:Mongo.DriverBootstrap = MongoDB / members /?
            {
                $0.executors = .shared(executors)
                $0.connectionTimeout = .milliseconds(1000)
            }

            await TestFsync             (tests, bootstrap: bootstrap)
            await TestDatabases         (tests, bootstrap: bootstrap)
            await TestListCollections   (tests, bootstrap: bootstrap)
            await TestInsert            (tests, bootstrap: bootstrap)
            await TestFind              (tests, bootstrap: bootstrap)

            await TestCausalConsistency (tests, bootstrap: MongoDB / members /?
            {
                $0.executors = .shared(executors)
                $0.connectionTimeout = .milliseconds(2000)
            })
            await TestTransactions      (tests, bootstrap: bootstrap)

            await TestCursors           (tests, bootstrap: bootstrap, on:
            [
                .primary,
                //  We should be able to run this test on a specific server.
                .nearest(tagSets: [["name": "B"]]),
                //  We should be able to run this test on a secondary.
                .nearest(tagSets: [["name": "C"]]),
            ])
        }

        if  let tests:TestGroup = tests / "single"
        {
            let seedlist:Mongo.Seedlist = ["mongo-single": 27017]
            let bootstrap:Mongo.DriverBootstrap = MongoDB / ("root", "80085") * seedlist /?
            {
                $0.authentication = .sasl(.sha256)
                $0.executors = .shared(executors)
            }

            await TestFsync             (tests, bootstrap: bootstrap)
            await TestDatabases         (tests, bootstrap: bootstrap)
            await TestListCollections   (tests, bootstrap: bootstrap)
            await TestInsert            (tests, bootstrap: bootstrap)
            await TestFind              (tests, bootstrap: bootstrap)

            await TestCursors           (tests, bootstrap: bootstrap, on: [.primary])
        }
    }
}
