import NIOPosix
import MongoDB
import Testing

@main
enum Main:AsyncTests
{
    static
    func run(tests:Tests) async
    {
        let executor:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        do
        {
            let tests:TestGroup = tests / "replicated-topology"

            let members:Set<Mongo.Host> =
            [
                .init(name: "mongo-0", port: 27017),
                .init(name: "mongo-1", port: 27017),
                .init(name: "mongo-2", port: 27017),
                .init(name: "mongo-3", port: 27017),
                .init(name: "mongo-4", port: 27017),
                .init(name: "mongo-5", port: 27017),
            ]
            
            print("running tests for replicated topology (hosts: \(members))")

            let bootstrap:Mongo.DriverBootstrap = .init(
                credentials: nil,
                executor: executor)

            await TestFsync     (tests, bootstrap: bootstrap, hosts: members)
            await TestDatabases (tests, bootstrap: bootstrap, hosts: members)
            await TestInsert    (tests, bootstrap: bootstrap, hosts: members)
            await TestFind      (tests, bootstrap: bootstrap, hosts: members)

            await TestCausalConsistency(tests, bootstrap: bootstrap, hosts: members)
            await TestTransactions(tests, bootstrap: bootstrap, hosts: members)

            await TestCursors(tests, bootstrap: bootstrap, hosts: members)
        }

        do
        {
            let tests:TestGroup = tests / "single"

            let standalone:Mongo.Host = .init(name: "mongo-single", port: 27017)

            print("running tests for single topology (host: \(standalone))")

            let bootstrap:Mongo.DriverBootstrap = .init(
                credentials: .init(authentication: .sasl(.sha256),
                    username: "root",
                    password: "80085"),
                executor: executor)

            await TestFsync(tests, bootstrap: bootstrap, hosts: [standalone])
            await TestDatabases(tests, bootstrap: bootstrap, hosts: [standalone])
            await TestInsert(tests, bootstrap: bootstrap, hosts: [standalone])
            await TestFind(tests, bootstrap: bootstrap, hosts: [standalone])

            await TestCursors(tests, bootstrap: bootstrap, hosts: [standalone])
        }
    }
}
