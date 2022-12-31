import NIOPosix
import MongoChannel
import MongoDriver
import MongoTopology
import Testing

@main
enum Main:AsyncTests
{
    static
    func run(tests:inout Tests) async
    {
        let executor:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

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
    }
}
extension Main
{
    static
    func run(tests:inout Tests, replicas:[MongoTopology.Host],
        on executor:MultiThreadedEventLoopGroup) async
    {
        print("running tests for replicated topology (hosts: \(replicas))")
        //  we should be able to connect to the primary using any seed
        await tests.group("replica-set-seeding")
        {
            for seed:MongoTopology.Host in replicas
            {
                await $0.test(with: DriverEnvironment.init(
                    name: "discover-primary-from-\(seed.name)",
                    credentials: nil,
                    executor: executor))
                {
                    try await $1.withSessionPool(seedlist: [seed])
                    {
                        try await $0.withMutableSession(timeout: .seconds(5))
                        {
                            //  TODO: actually check these values
                            let _:Mongo.ReplicaSetConfiguration = try await $0.run(
                                command: Mongo.ReplicaSetGetConfiguration.init())
                        }
                    }
                }
            }
        }
        // await tests.test(with: DriverEnvironment.init(
        //     name: "replica-set-cluster-times",
        //     credentials: nil,
        //     executor: executor))
        // {
        //     (tests:inout Tests, driver:Mongo.DriverBootstrap) in

        //     try await driver.withSessionPool(seedlist: .init(replicas))
        //     {
        //         try await $0.withMutableSession(timeout: .seconds(5))
        //         {
        //             // should be `nil` here, but eventually we want to get
        //             // `$clusterTime` from Hellos too
        //             // print($0.monitor.clusterTime)

        //             let _:Mongo.ReplicaSetConfiguration = try await $0.run(
        //                 command: Mongo.ReplicaSetGetConfiguration.init())
                    
        //             let original:Mongo.ClusterTime? = tests.unwrap($0.monitor.clusterTime,
        //                 name: "first")

        //             //  mongod only updates its timestamps on write, or every 10s.
        //             //  we don’t have any commands in this module that write, so we
        //             //  just have to wait 10s...

        //             //  TODO: figure out a way to perturb the cluster time without
        //             //  waiting 10s
        //             try await Task.sleep(for: .milliseconds(10000))

        //             let _:Mongo.ReplicaSetConfiguration = try await $0.run(
        //                 command: Mongo.ReplicaSetGetConfiguration.init())
                    
        //             if  let updated:Mongo.ClusterTime = tests.unwrap($0.monitor.clusterTime,
        //                     name: "second"),
        //                 let original:Mongo.ClusterTime
        //             {
        //                 tests.assert(original.max != updated.max,
        //                     name: "updated")
        //             }
                        
        //         }
        //     }
        // }
    }
    static
    func run(tests:inout Tests, single:MongoTopology.Host,
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
                try await $1.withSessionPool(seedlist: [single])
                {
                    try await $0.withMutableSession { _ in }
                }
            }
            await $0.test(with: DriverEnvironment.init(name: "seeded-twice",
                credentials: nil, executor: executor))
            {
                try await $1.withSessionPool(seedlist: [single])
                {
                    try await $0.withMutableSession { _ in }
                }
                try await $1.withSessionPool(seedlist: [single])
                {
                    try await $0.withMutableSession { _ in }
                }
            }
            await $0.test(with: DriverEnvironment.init(name: "seeded-concurrently",
                credentials: nil, executor: executor))
            {
                async
                let first:Void = $1.withSessionPool(seedlist: [single])
                {
                    try await $0.withMutableSession
                    {
                        _ in try await Task.sleep(for: .milliseconds(100))
                    }
                }
                async
                let second:Void = $1.withSessionPool(seedlist: [single])
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
                    try await $1.withSessionPool(seedlist: [single])
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
                await $1.withSessionPool(seedlist: [single])
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
                try await $1.withSessionPool(seedlist: [single])
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
                try await $1.withSessionPool(seedlist: [single])
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
            (tests:inout Tests, driver:Mongo.DriverBootstrap) in

            await tests.test(name: "errors-equal",
                expecting: Mongo.SessionMediumError.init(
                    selector: .any, 
                    errored:
                    [
                        single: Mongo.AuthenticationError.init(
                                Mongo.AuthenticationUnsupportedError.init(.x509),
                            credentials: driver.credentials!)
                    ]))
            {
                _ in
                try await driver.withSessionPool(seedlist: [single])
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
            (tests:inout Tests, driver:Mongo.DriverBootstrap) in

            await tests.test(name: "errors-equal",
                expecting: Mongo.SessionMediumError.init(
                    selector: .any, 
                    errored:
                    [
                        single: Mongo.AuthenticationError.init(
                                MongoChannel.ServerError.init(
                                    message: "Authentication failed.",
                                    code: 18),
                            credentials: driver.credentials!)
                    ]))
            {
                _ in
                try await driver.withSessionPool(seedlist: [single])
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