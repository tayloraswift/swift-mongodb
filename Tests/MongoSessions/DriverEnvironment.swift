import Testing
import MongoSessions
import NIOPosix

struct DriverEnvironment
{
    let driver:Mongo.Driver
    let name:String

    init(name:String, credentials:Mongo.Credentials?, executor:MultiThreadedEventLoopGroup)
    {
        self.driver = .init(certificatePath: nil,
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
        body:(inout Tests, Mongo.Driver) async throws -> Success) async throws -> Success
    {
        try await body(&tests, self.driver)
    }
}
