import MongoDriver
import NIOPosix
import Testing

@main
enum Main:AsyncTests
{
    static
    func run(tests:Tests) async
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

        do
        {
            let tests:TestGroup = tests / "replicated-topology"

            print("running tests for replicated topology (hosts: \(members))")

            let seedlist:Set<Mongo.Host> = .init(members)

            await TestSessionPool(tests, credentials: nil,
                seedlist: seedlist,
                on: executor)
            
            await TestConnectionPool(tests, credentials: nil,
                seedlist: seedlist,
                on: executor)
            
            let bootstrap:Mongo.DriverBootstrap = .init(credentials: nil,
                executor: executor)
            
            await TestMemberDiscovery(tests, bootstrap: bootstrap, members: members)
            await TestReadPreference(tests, bootstrap: bootstrap, members: members)
        }

        do
        {
            let tests:TestGroup = tests / "single-topology"

            print("running tests for single topology (host: \(standalone))")

            let credentials:Mongo.Credentials = .init(authentication: .sasl(.sha256),
                username: "root",
                password: "80085")

            await TestAuthentication(tests, standalone: standalone,
                username: credentials.username,
                password: credentials.password,
                on: executor)
            
            await TestSessionPool(tests, credentials: credentials,
                seedlist: [standalone],
                on: executor)
            
            await TestConnectionPool(tests, credentials: credentials,
                seedlist: [standalone],
                on: executor)
        }
    }
}
