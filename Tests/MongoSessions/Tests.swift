import Testing
import MongoSessions
import NIOPosix

extension Tests
{
    mutating
    func with(credentials:Mongo.Credentials?,
        timeout:Mongo.Milliseconds = .seconds(10),
        loops:MultiThreadedEventLoopGroup,
        test:@Sendable (inout Self, Mongo.Driver) async throws -> ()) async rethrows
    {
        let driver:Mongo.Driver = .init(
            credentials: credentials,
            timeout: timeout,
            loops: loops)
        
        try await test(&self, driver)
    }
    mutating
    func test(name:String, credentials:Mongo.Credentials?,
        timeout:Mongo.Milliseconds = .seconds(10),
        loops:MultiThreadedEventLoopGroup,
        test:@Sendable (inout Self, Mongo.Driver) async throws -> ()) async
    {
        await self.with(credentials: credentials, timeout: timeout, loops: loops)
        {
            (tests:inout Self, driver:Mongo.Driver) in
            await tests.do(name: name)
            {
                try await test(&$0, driver)
            }
        }
    }
    // mutating
    // func test(name:String, credentials:Mongo.Credentials?,
    //     expecting failure:some Equatable & Error,
    //     timeout:Mongo.Milliseconds = .seconds(10),
    //     loops:MultiThreadedEventLoopGroup,
    //     test:@Sendable (inout Self, Mongo.Driver) async throws -> ()) async
    // {
    //     await self.do(name: name, expecting: failure)
    //     {
    //         let driver:Mongo.Driver = .init(
    //             credentials: credentials,
    //             timeout: timeout,
    //             loops: loops)
            
    //         try await test(&$0, driver)
    //     }
    // }
}
