import NIOPosix
import MongoSessions
import Testing

@main 
enum Main:AsyncTests
{
    static
    func run(tests:inout Tests) async
    {
        let host:Mongo.Host = .init(name: "mongodb", port: 27017)
        let executor:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
        
        //  these tests ensure we do proper cleanup on all exit paths.
        //  they use no assertions, but should trip sanity checks within
        //  the driver’s `deinit`s if cleanup is not performed correctly.
        await tests.group("lifecycles")
        {
            await $0.test(with: DriverEnvironment.init(name: "seeded-once",
                credentials: nil,
                executor: executor))
            {
                try await $1.seeded(with: [host])
                {
                    try await $0.withMutableSession { _ in }
                }
            }
            await $0.test(with: DriverEnvironment.init(name: "seeded-twice",
                credentials: nil, executor: executor))
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
            await $0.test(with: DriverEnvironment.init(name: "seeded-concurrently",
                credentials: nil, executor: executor))
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

            await $0.test(with: DriverEnvironment.init(name: "error-pool",
                credentials: nil, executor: executor))
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

            await $0.test(with: DriverEnvironment.init(name: "error-session",
                credentials: nil, executor: executor))
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
            await $0.test(with: DriverEnvironment.init(name: "defaulted",
                credentials: .init(authentication: nil,
                    username: "root",
                    password: "password"),
                executor: executor))
            {
                try await $1.seeded(with: [host])
                {
                    try await $0.withMutableSession
                    {
                        _ in
                    }
                }
            }

            await $0.test(with: DriverEnvironment.init(name: "scram-sha256",
                credentials: .init(authentication: .sasl(.sha256),
                    username: "root",
                    password: "password"),
                executor: executor))
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

        await tests.test(with: DriverEnvironment.init(name: "authentication-unsupported",
            credentials: .init(authentication: .x509,
                username: "root",
                password: "password"),
            executor: executor))
        {
            (tests:inout Tests, driver:Mongo.Driver) in

            await tests.test(name: "errors-equal",
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

        await tests.test(with: DriverEnvironment.init(name: "authentication-wrong-password",
            credentials: .init(authentication: .sasl(.sha256),
                username: "root",
                password: "1234"),
            executor: executor))
        {
            (tests:inout Tests, driver:Mongo.Driver) in

            await tests.test(name: "errors-equal",
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
