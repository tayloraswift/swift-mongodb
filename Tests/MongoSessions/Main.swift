import NIOPosix
import MongoSessions
import Testing

@main 
enum Main:AsynchronousTests
{
    static
    func run(tests:inout Tests) async
    {
        let host:Mongo.Host = .init(name: "mongodb", port: 27017)
        let loops:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
        
        //  these tests ensure we do proper cleanup on all exit paths.
        //  they use no assertions, but should trip sanity checks within
        //  the driver’s `deinit`s if cleanup is not performed correctly.
        await tests.group("lifecycles")
        {
            await $0.test(name: "seeded-once",
                credentials: nil,
                loops: loops)
            {
                try await $1.seeded(with: [host])
                {
                    try await $0.withMutableSession { _ in }
                }
            }
            await $0.test(name: "seeded-twice",
                credentials: nil,
                loops: loops)
            {
                try await $1.seeded(with: [host])
                {
                    try await $0.withMutableSession { _ in }
                }
                try await $1.seeded(with: [host])
                {
                    try await $0.withMutableSession { _ in }
                }
            }
            await $0.test(name: "seeded-concurrently",
                credentials: nil,
                loops: loops)
            {
                async
                let first:Void = $1.seeded(with: [host])
                {
                    try await $0.withMutableSession
                    {
                        _ in try await Task.sleep(for: .milliseconds(100))
                    }
                }
                async
                let second:Void = $1.seeded(with: [host])
                {
                    try await $0.withMutableSession
                    {
                        _ in try await Task.sleep(for: .milliseconds(100))
                    }
                }

                try await first
                try await second
            }

            await $0.test(name: "error-pool",
                credentials: nil,
                loops: loops)
            {
                do
                {
                    try await $1.seeded(with: [host])
                    {
                        async
                        let _:Void = $0.withMutableSession { _ in }
                        throw CancellationError.init()
                    }
                }
                catch is CancellationError
                {
                }
            }

            await $0.test(name: "error-session",
                credentials: nil,
                loops: loops)
            {
                await $1.seeded(with: [host])
                {
                    async
                    let _:Void = $0.withMutableSession { _ in }
                    async
                    let _:Void = $0.withMutableSession
                    {
                        _ in throw CancellationError.init()
                    }
                }
            }
        }
        await tests.group("authentication")
        {
            // since we do not perform any operations, this should succeed
            // await $0.do(name: "none")
            // {
            //     _ in 
            //     let _:Mongo.SessionPool = .init(
            //         settings: .init(timeout: .seconds(10)),
            //         group: group,
            //         seeds:
            //         [
            //             host,
            //         ])
            // }

            await $0.test(name: "defaulted",
                credentials: .init(authentication: nil,
                    username: "root",
                    password: "password"),
                loops: loops)
            {
                try await $1.seeded(with: [host])
                {
                    try await $0.withMutableSession
                    {
                        _ in
                    }
                }
            }

            await $0.test(name: "scram-sha256",
                credentials: .init(authentication: .sasl(.sha256),
                    username: "root",
                    password: "password"),
                loops: loops)
            {
                try await $1.seeded(with: [host])
                {
                    try await $0.withMutableSession
                    {
                        _ in
                    }
                }
            }
        }

        await tests.with(credentials: .init(authentication: .x509,
                username: "root",
                password: "password"),
            
            loops: loops)
        {
            (tests:inout Tests, driver:Mongo.Driver) in

            await tests.do(name: "authentication-unsupported",
                expecting: Mongo.SessionMediumError.init(
                    selector: .master, 
                    errored:
                    [
                        host: Mongo.AuthenticationError.init(
                                Mongo.AuthenticationUnsupportedError.init(.x509),
                            credentials: driver.credentials!)
                    ]))
            {
                _ in
                try await driver.seeded(with: [host])
                {
                    try await $0.withMutableSession(timeout: .milliseconds(500))
                    {
                        _ in
                    }
                }
            }
        }

        await tests.with(credentials: .init(authentication: .sasl(.sha256),
                username: "root",
                password: "1234"),
            loops: loops)
        {
            (tests:inout Tests, driver:Mongo.Driver) in

            await tests.do(name: "authentication-wrong-password",
                expecting: Mongo.SessionMediumError.init(
                    selector: .master, 
                    errored:
                    [
                        host: Mongo.AuthenticationError.init(
                                Mongo.ServerError.init(message: "Authentication failed."),
                            credentials: driver.credentials!)
                    ]))
            {
                _ in
                try await driver.seeded(with: [host])
                {
                    try await $0.withMutableSession(timeout: .milliseconds(500))
                    {
                        _ in
                    }
                }
            }
        }
    }
}
