import Testing
import MongoDriver

struct SessionEnvironment
{
    let name:String
    let pool:Mongo.SessionPool

    init(name:String, pool:Mongo.SessionPool)
    {
        self.name = name
        self.pool = pool
    }
}
extension SessionEnvironment:AsyncTestEnvironment
{
    func runWithContext<Success>(tests:inout Tests,
        body:(inout Tests, Mongo.MutableSession) async throws -> Success) async throws -> Success
    {
        try await self.pool.withMutableSession { try await body(&tests, $0) }
    }
}
