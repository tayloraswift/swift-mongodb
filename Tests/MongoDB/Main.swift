import NIOPosix
import MongoDB
import MongoTopology
import Testing

@main
enum Main:AsyncTests
{
    static
    func run(tests:inout Tests) async
    {
        let executor:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        await tests.group("replicated-topology")
        {
            let members:Set<MongoTopology.Host> =
            [
                .init(name: "mongo-1", port: 27017),
                .init(name: "mongo-2", port: 27017),
                .init(name: "mongo-3", port: 27017),
            ]
            
            print("running tests for replicated topology (hosts: \(members))")

            let bootstrap:Mongo.DriverBootstrap = .init(
                commandTimeout: .seconds(10),
                credentials: nil,
                executor: executor)

            await TestFsync(&$0, bootstrap: bootstrap, hosts: members)
            await TestDatabases(&$0, bootstrap: bootstrap, hosts: members)
            await TestInsert(&$0, bootstrap: bootstrap, hosts: members)
            await TestFind(&$0, bootstrap: bootstrap, hosts: members)
            await TestCursors(&$0, bootstrap: bootstrap, hosts: members)
        }

        await tests.group("single-topology")
        {
            let standalone:MongoTopology.Host = .init(name: "mongo-single", port: 27017)

            print("running tests for single topology (host: \(standalone))")

            let bootstrap:Mongo.DriverBootstrap = .init(
                commandTimeout: .seconds(10),
                credentials: .init(authentication: .sasl(.sha256),
                    username: "root",
                    password: "80085"),
                executor: executor)

            await TestFsync(&$0, bootstrap: bootstrap, hosts: [standalone])
            await TestDatabases(&$0, bootstrap: bootstrap, hosts: [standalone])
            await TestInsert(&$0, bootstrap: bootstrap, hosts: [standalone])
            await TestFind(&$0, bootstrap: bootstrap, hosts: [standalone])
            await TestCursors(&$0, bootstrap: bootstrap, hosts: [standalone])
        }
    }
}
