import MongoDriver
import MongoTopology
import NIOPosix
import Testing

func TestMemberDiscovery(_ tests:inout Tests, members:[MongoTopology.Host],
    on executor:MultiThreadedEventLoopGroup) async
{
    //  we should be able to connect to the primary using any seed
    await tests.group("seeding")
    {
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
                            command: Mongo.ReplicaSetGetConfiguration.init(),
                            on: .primary)
                        //  this was the configuration we initialized the test set with:
                        //  (/.github/mongonet/create-replica-set.js)

                        //  we can’t assert the configuration as a whole, because the
                        //  term will increment on its own.
                        tests.assert(configuration.name ==? "test-set",
                            name: "configuration-name")
                        
                        tests.assert(configuration.writeConcernMajorityJournalDefault ==? true,
                            name: "configuration-journaling")
                        
                        tests.assert(configuration.members ..?
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
                            name: "configuration-members")
                        
                        tests.assert(configuration.version ==? 1,
                            name: "configuration-version")
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
