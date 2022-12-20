import NIOPosix
import MongoSessions
import Testing

@main
enum Main
{
    public static
    func main() async
    {
        var tests:Tests = .init()
        await Self.run(tests: &tests)
        print(tests.results.passed)
        print(tests.results.failed)
    }

    static
    func run(tests:inout Tests) async
    {
        let executor:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

        switch CommandLine.arguments.count
        {
        case 1:
            //  default configuration, for local testing
            await self.run(tests: &tests, single: .init(name: "mongo-single", port: 27017),
                on: executor)
            await self.run(tests: &tests,
                replicas:
                [
                    .init(name: "mongo-1", port: 27017),
                    .init(name: "mongo-2", port: 27017),
                    .init(name: "mongo-3", port: 27017),
                ],
                on: executor)
        
        case 2:
            //  ci configuration, runs single-topology tests
            await self.run(tests: &tests, single: .init(CommandLine.arguments[1]),
                on: executor)
        
        case 3...:
            //  ci configuration, runs replicated-topology tests
            await self.run(tests: &tests, 
                replicas: CommandLine.arguments.dropFirst().map(Mongo.Host.init(_:)),
                on: executor)
        
        default:
            fatalError("unreachable")
        }
    }
}
extension Main
{
    static
    func run(tests:inout Tests, replicas:[Mongo.Host],
        on executor:MultiThreadedEventLoopGroup) async
    {
        print("running tests for replicated topology (hosts: \(replicas))")
        //  we should be able to connect to the primary using any seed
        await tests.group("replication")
        {
            for seed:Mongo.Host in replicas
            {
                await $0.test(with: DriverEnvironment.init(
                    name: "discover-primary-from-\(seed.name)",
                    credentials: nil,
                    executor: executor))
                {
                    try await $1.seeded(with: [seed])
                    {
                        try await $0.withMutableSession(timeout: .seconds(5))
                        {
                            _ in
                        }
                    }
                }
            }
        }
    }
    static
    func run(tests:inout Tests, single:Mongo.Host,
        on executor:MultiThreadedEventLoopGroup) async
    {
        print("running tests for single topology (host: \(single))")
        //  these tests ensure we do proper cleanup on all exit paths.
        //  they use no assertions, but should trip sanity checks within
        //  the driver’s `deinit`s if cleanup is not performed correctly.
        await tests.group("lifecycles")
        {
            await $0.test(with: DriverEnvironment.init(name: "seeded-once",
                credentials: nil,
                executor: executor))
            {
                try await $1.seeded(with: [single])
                {
                    try await $0.withMutableSession { _ in }
                }
            }
            await $0.test(with: DriverEnvironment.init(name: "seeded-twice",
                credentials: nil, executor: executor))
            {
                try await $1.seeded(with: [single])
                {
                    try await $0.withMutableSession { _ in }
                }
                try await $1.seeded(with: [single])
                {
                    try await $0.withMutableSession { _ in }
                }
            }
            await $0.test(with: DriverEnvironment.init(name: "seeded-concurrently",
                credentials: nil, executor: executor))
            {
                async
                let first:Void = $1.seeded(with: [single])
                {
                    try await $0.withMutableSession
                    {
                        _ in try await Task.sleep(for: .milliseconds(100))
                    }
                }
                async
                let second:Void = $1.seeded(with: [single])
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
                    try await $1.seeded(with: [single])
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
                await $1.seeded(with: [single])
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
                    password: "80085"),
                executor: executor))
            {
                try await $1.seeded(with: [single])
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
                    password: "80085"),
                executor: executor))
            {
                try await $1.seeded(with: [single])
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
                password: "80085"),
            executor: executor))
        {
            (tests:inout Tests, driver:Mongo.Driver) in

            await tests.test(name: "errors-equal",
                expecting: Mongo.SessionMediumError.init(
                    selector: .master, 
                    errored:
                    [
                        single: Mongo.AuthenticationError.init(
                                Mongo.AuthenticationUnsupportedError.init(.x509),
                            credentials: driver.credentials!)
                    ]))
            {
                _ in
                try await driver.seeded(with: [single])
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
                        single: Mongo.AuthenticationError.init(
                                Mongo.ServerError.init(message: "Authentication failed."),
                            credentials: driver.credentials!)
                    ]))
            {
                _ in
                try await driver.seeded(with: [single])
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