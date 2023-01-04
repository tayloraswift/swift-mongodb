import MongoDriver
import MongoTopology
import NIOPosix
import Testing

@main
enum Main:AsyncTests
{
    static
    func run(tests:inout Tests) async
    {
        let executor:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        let standalone:MongoTopology.Host = .init(name: "mongo-single", port: 27017)
        let members:[MongoTopology.Host] =
        [
            .init(name: "mongo-1", port: 27017),
            .init(name: "mongo-2", port: 27017),
            .init(name: "mongo-3", port: 27017),
        ]

        await tests.group("replicated-topology")
        {
            print("running tests for replicated topology (hosts: \(members))")

            await TestSessionPool(&$0, credentials: nil,
                seedlist: .init(members),
                on: executor)
            
            await TestMemberDiscovery(&$0,
                members: members,
                on: executor)
        }

        await tests.group("single-topology")
        {
            print("running tests for single topology (host: \(standalone))")

            let credentials:Mongo.Credentials = .init(authentication: .sasl(.sha256),
                username: "root",
                password: "80085")

            await TestSessionPool(&$0, credentials: credentials,
                seedlist: [standalone],
                on: executor)
            
            await TestAuthentication(&$0, credentials: credentials,
                standalone: standalone,
                on: executor)
        }
    }
}
