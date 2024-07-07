import MongoDriver
import Testing_

func TestMemberDiscovery(_ tests:TestGroup,
    members:Mongo.Seedlist,
    matrix:KeyValuePairs<String, Mongo.DriverBootstrap>) async
{
    //  we should be able to connect to the primary using any seed
    for (name, bootstrap):(String, Mongo.DriverBootstrap) in matrix
    {
        guard let tests:TestGroup = tests / "discovery" / name
        else
        {
            continue
        }

        await tests.do
        {
            try await bootstrap.withSessionPool
            {
                let session:Mongo.Session = try await .init(from: $0)
                let configuration:Mongo.ReplicaSetConfiguration = try await session.run(
                    command: Mongo.ReplicaSetGetConfiguration.init(),
                    against: .admin,
                    on: .primary)
                //  this was the configuration we initialized the test set with:
                //  (/.github/mongonet/create-replica-set.js)

                //  we can’t assert the configuration as a whole, because the
                //  term will increment on its own.
                tests.expect(configuration.name ==? "test-set")

                tests.expect(configuration.writeConcernMajorityJournalDefault ==? true)

                tests.expect(configuration.members ..?
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
                            rights: .resident(.init(buildsIndexes: true, delay: .seconds(5))),
                            votes: 0,
                            tags: ["priority": "zero", "name": "H"])),

                        .init(id: 5, host: members[5], replica: nil),

                        .init(id: 6, host: members[6], replica: .init(
                            rights: .resident,
                            votes: 0,
                            tags: ["priority": "zero", "name": "E"])),
                    ])

                tests.expect(configuration.version ==? 1)
            }
        }
    }
}
