import MongoDriver
import Testing

func TestMemberDiscovery(_ tests:inout Tests,
    bootstrap:Mongo.DriverBootstrap,
    members:[Mongo.Host]) async
{
    //  we should be able to connect to the primary using any seed
    for seed:Mongo.Host in members
    {
        await tests.test(name: "discover-primary-from-\(seed.name)")
        {
            (tests:inout Tests) in

            try await bootstrap.withSessionPool(seedlist: [seed],
                timeout: .init(milliseconds: 3000))
            {
                try await $0.withSession
                {
                    let configuration:Mongo.ReplicaSetConfiguration = try await $0.run(
                        command: Mongo.ReplicaSetGetConfiguration.init(),
                        against: .admin,
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
                            .init(id: 0, host: members[0], replica: .init(
                                rights: .init(priority: 2.0),
                                votes: 1,
                                tags: ["priority": "high", "name": "A"])),
                            
                            .init(id: 1, host: members[1], replica: .init(
                                rights: .init(priority: 1.0),
                                votes: 1,
                                tags: ["priority": "low", "name": "B"])),
                            
                            .init(id: 2, host: members[2], replica: .init(
                                rights: .resident,
                                votes: 1,
                                tags: ["priority": "zero", "name": "C"])),
                            
                            .init(id: 3, host: members[3], replica: .init(
                                rights: .resident,
                                votes: 1,
                                tags: ["priority": "zero", "name": "D"])),
                            
                            .init(id: 4, host: members[4], replica: .init(
                                rights: .resident(.init(buildsIndexes: true, delay: 5)),
                                votes: 0,
                                tags: ["priority": "zero", "name": "H"])),
                            
                            .init(id: 5, host: members[5], replica: nil),
                        ],
                        name: "configuration-members")
                    
                    tests.assert(configuration.version ==? 1,
                        name: "configuration-version")
                }
            }
        }
    }
}
