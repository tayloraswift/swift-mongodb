import MongoConfiguration
import MongoDriver
import NIOPosix
import Testing

@Suite struct MemberDiscovery
{
    @Test(arguments: [0, 1, 2, 3, 4, 5, 6])
    static func memberDiscovery(_ i:Int) async throws
    {
        let bootstrap:Mongo.DriverBootstrap = mongodb / .replicated(i ... i) /?
        {
            $0.executors = .shared(MultiThreadedEventLoopGroup.singleton)
        }
        //  We should be able to connect to the master using any seed
        try await bootstrap.withSessionPool
        {
            let session:Mongo.Session = try await .init(from: $0)
            let configuration:Mongo.ReplicaSetConfiguration = try await session.run(
                command: Mongo.ReplicaSetGetConfiguration.init(),
                against: .admin,
                on: .primary)
            //  This was the configuration we initialized the test set with:
            //  (/.github/mongonet/create-replica-set.js)

            //  We can’t assert the configuration as a whole, because the
            //  term will increment on its own.
            #expect(configuration.name == "test-set")
            #expect(configuration.writeConcernMajorityJournalDefault == true)

            #expect(configuration.members == [
                    .init(id: 0, host: Mongo.Seedlist.replicated[0], replica: .init(
                        rights: .init(priority: 2.0),
                        votes: 1,
                        tags: ["priority": "high", "name": "A"])),

                    .init(id: 1, host: Mongo.Seedlist.replicated[1], replica: .init(
                        rights: .init(priority: 1.0),
                        votes: 1,
                        tags: ["priority": "low", "name": "B"])),

                    .init(id: 2, host: Mongo.Seedlist.replicated[2], replica: .init(
                        rights: .resident,
                        votes: 1,
                        tags: ["priority": "zero", "name": "C"])),

                    .init(id: 3, host: Mongo.Seedlist.replicated[3], replica: .init(
                        rights: .resident,
                        votes: 1,
                        tags: ["priority": "zero", "name": "D"])),

                    .init(id: 4, host: Mongo.Seedlist.replicated[4], replica: .init(
                        rights: .resident(.init(buildsIndexes: true, delay: .seconds(5))),
                        votes: 0,
                        tags: ["priority": "zero", "name": "H"])),

                    .init(id: 5, host: Mongo.Seedlist.replicated[5], replica: nil),

                    .init(id: 6, host: Mongo.Seedlist.replicated[6], replica: .init(
                        rights: .resident,
                        votes: 0,
                        tags: ["priority": "zero", "name": "E"])),
                ])

            #expect(configuration.version == 1)
        }
    }
}
