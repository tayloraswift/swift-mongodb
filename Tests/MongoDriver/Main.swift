import MongoDriver
import NIOPosix
import Testing

@main
enum Main:AsyncTests
{
    static
    func run(tests:inout Tests) async
    {
        let executor:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        let standalone:Mongo.Host = .init(name: "mongo-single", port: 27017)
        let members:[Mongo.Host] =
        [
            .init(name: "mongo-0", port: 27017),
            .init(name: "mongo-1", port: 27017),
            .init(name: "mongo-2", port: 27017),
            .init(name: "mongo-3", port: 27017),
            .init(name: "mongo-4", port: 27017),
            .init(name: "mongo-5", port: 27017),
        ]

        await tests.group("replicated-topology")
        {
            print("running tests for replicated topology (hosts: \(members))")

            await TestSessionPool(&$0, credentials: nil,
                seedlist: .init(members),
                on: executor)
            let bootstrap:Mongo.DriverBootstrap = .init(credentials: nil,
                executor: executor)
            
            await TestMemberDiscovery(&$0, bootstrap: bootstrap, members: members)
            await TestReadPreference(&$0, bootstrap: bootstrap, members: members)
        }

        await tests.group("single-topology")
        {
            print("running tests for single topology (host: \(standalone))")

            let credentials:Mongo.Credentials = .init(authentication: .sasl(.sha256),
                username: "root",
                password: "80085")

            await TestAuthentication(&$0, standalone: standalone,
                username: credentials.username,
                password: credentials.password,
                on: executor)
            
            await TestSessionPool(&$0, credentials: credentials,
                seedlist: [standalone],
                on: executor)
        }
    }
}
