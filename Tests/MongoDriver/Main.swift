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
            members:
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
    func run(tests:inout Tests, members:[MongoTopology.Host],
        on executor:MultiThreadedEventLoopGroup) async
    {
        print("running tests for replicated topology (hosts: \(members))")
        //  we should be able to connect to the primary using any seed
        await tests.group("replica-set-seeding")
        {
            //  this was the configuration we initialized the test set with:
            //  (/.github/mongonet/create-replica-set.js)
            let expected:Mongo.ReplicaSetConfiguration = .init(name: "test-set",
                writeConcernMajorityJournalDefault: true,
                members:
                [
                    .init(id: 1, host: members[0], replica: .init(
                        rights: .init(priority: 2.0),
                        votes: 1,
                        tags: ["c": "C", "a": "A", "b": "B"])),
                    
                    .init(id: 2, host: members[1], replica: .init(
                        rights: .init(priority: 1.0),
                        votes: 1,
                        tags: ["b": "B", "d": "D", "c": "C"])),
                    
                    .init(id: 3, host: members[2], replica: nil),
                ],
                version: 1,
                term: 1)
            
            for seed:MongoTopology.Host in members
            {
                await $0.test(with: DriverEnvironment.init(
                    name: "discover-primary-from-\(seed.name)",
                    credentials: nil,
                    executor: executor))
                {
                    (tests:inout Tests, bootstrap:Mongo.DriverBootstrap) in

                    try await bootstrap.withSessionPool(seedlist: [seed])
                    {
                        try await $0.withSession(connectionTimeout: .seconds(5))
                        {
                            let configuration:Mongo.ReplicaSetConfiguration = try await $0.run(
                                command: Mongo.ReplicaSetGetConfiguration.init())
                            
                            tests.assert(configuration ==? expected, name: "configuration")
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
        //     (tests:inout Tests, bootstrap:Mongo.DriverBootstrap) in

        //     try await bootstrap.withSessionPool(seedlist: .init(members))
        //     {
        //         try await $0.withSession(connectionTimeout: .seconds(5))
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
                    try await $0.withSession { _ in }
                }
            }
            await $0.test(with: DriverEnvironment.init(name: "seeded-twice",
                credentials: nil, executor: executor))
            {
                try await $1.withSessionPool(seedlist: [single])
                {
                    try await $0.withSession { _ in }
                }
                try await $1.withSessionPool(seedlist: [single])
                {
                    try await $0.withSession { _ in }
                }
            }
            await $0.test(with: DriverEnvironment.init(name: "seeded-concurrently",
                credentials: nil, executor: executor))
            {
                async
                let first:Void = $1.withSessionPool(seedlist: [single])
                {
                    try await $0.withSession
                    {
                        _ in try await Task.sleep(for: .milliseconds(100))
                    }
                }
                async
                let second:Void = $1.withSessionPool(seedlist: [single])
                {
                    try await $0.withSession
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
                        let _:Void = $0.withSession { _ in }
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
                    let _:Void = $0.withSession { _ in }
                    async
                    let _:Void = $0.withSession
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
                    try await $0.withSession
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
                    try await $0.withSession
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
            (tests:inout Tests, bootstrap:Mongo.DriverBootstrap) in

            await tests.test(name: "errors-equal",
                expecting: Mongo.ClusterError<Mongo.LogicalSessionsError>.init(
                    diagnostics: .init(unreachable:
                    [
                        single: .errored(Mongo.AuthenticationError.init(
                                Mongo.AuthenticationUnsupportedError.init(.x509),
                            credentials: bootstrap.credentials!))
                    ]),
                    failure: .init()))
            {
                _ in
                try await bootstrap.withSessionPool(seedlist: [single])
                {
                    try await $0.withSession(connectionTimeout: .milliseconds(500))
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
            (tests:inout Tests, bootstrap:Mongo.DriverBootstrap) in

            await tests.test(name: "errors-equal",
                expecting: Mongo.ClusterError<Mongo.LogicalSessionsError>.init(
                    diagnostics: .init(unreachable:
                    [
                        single: .errored(Mongo.AuthenticationError.init(
                                MongoChannel.ServerError.init(
                                    message: "Authentication failed.",
                                    code: 18),
                            credentials: bootstrap.credentials!))
                    ]),
                    failure: .init()))
            {
                _ in
                try await bootstrap.withSessionPool(seedlist: [single])
                {
                    try await $0.withSession(connectionTimeout: .milliseconds(500))
                    {
                        _ in
                    }
                }
            }
        }
    }
}