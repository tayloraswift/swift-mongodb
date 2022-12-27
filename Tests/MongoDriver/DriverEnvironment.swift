import Testing
import MongoDriver
import NIOPosix

struct DriverEnvironment
{
    let bootstrap:Mongo.DriverBootstrap
    let name:String

    init(name:String, credentials:Mongo.Credentials?, executor:MultiThreadedEventLoopGroup)
    {
        self.bootstrap = .init(certificatePath: nil,
            credentials: credentials,
            resolver: nil,
            executor: executor,
            timeout: .seconds(10),
            appname: name)
        self.name = name
    }
}
extension DriverEnvironment:AsyncTestEnvironment
{
    func runWithContext<Success>(tests:inout Tests,
        body:(inout Tests, Mongo.DriverBootstrap) async throws -> Success)
        async throws -> Success
    {
        try await body(&tests, self.bootstrap)
    }
}
