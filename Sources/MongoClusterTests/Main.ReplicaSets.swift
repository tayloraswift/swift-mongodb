import Testing_
import MongoClusters

extension Main
{
    enum ReplicaSets
    {
    }
}
extension Main.ReplicaSets:TestBattery
{
    static
    func run(tests:TestGroup) async throws
    {
        final
        class Void
        {
            init() {}
        }

        let localhost:Mongo.Host = .init(name: "localhost")
        let secondary:Mongo.Host = .init(name: "secondary")
        let primary:Mongo.Host = .init(name: "primary")
        let setName:String = "example-rs"

        /// Mocked peerlist.
        let peerlist:Mongo.Peerlist = .init(set: setName,
            primary: primary,
            arbiters: [],
            passives: [],
            hosts: [primary, secondary],
            me: primary)
        /// Mocked replica metadata.
        let filler:Mongo.Replica = .init(capabilities: .init(
                logicalSessionTimeoutMinutes: 1,
                maxWriteBatchCount: 1,
                maxDocumentSize: 1,
                maxMessageSize: 1),
            timings: .init(write: .zero),
            tags: [:])

        if  let tests:TestGroup = tests / "PrimaryRenameWithoutHint"
        {
            var topology:Mongo.Topology<Void> = .init(from: [localhost], hint: nil)
            let update:Mongo.TopologyUpdateResult = topology.combine(
                update: .primary(.init(replica: filler, term: .init(
                        election: .init(0, 0, 0),
                        version: 1)),
                    peerlist),
                owner: Void.init(),
                host: localhost)
            {
                _ in
            }

            tests.expect(update ==? .rejected)

            guard
            case .replicated(let replicated) = topology
            else
            {
                tests.expect(value: nil as Mongo.Topology<Void>.Replicated?)
                return
            }
            guard
            case .queued? = replicated[primary]
            else
            {
                tests.expect(true: false)
                return
            }
        }
        if  let tests:TestGroup = tests / "PrimaryRenameWithHint"
        {
            var topology:Mongo.Topology<Void> = .init(from: [localhost],
                hint: .replicated(set: setName))

            let update:Mongo.TopologyUpdateResult = topology.combine(
                update: .primary(.init(replica: filler, term: .init(
                        election: .init(0, 0, 0),
                        version: 1)),
                    peerlist),
                owner: Void.init(),
                host: localhost)
            {
                _ in
            }

            tests.expect(update ==? .rejected)

            guard
            case .replicated(let replicated) = topology
            else
            {
                tests.expect(value: nil as Mongo.Topology<Void>.Replicated?)
                return
            }
            guard
            case .queued? = replicated[primary]
            else
            {
                tests.expect(true: false)
                return
            }
        }
        if  let tests:TestGroup = tests / "GHOSTED"
        {
            var topology:Mongo.Topology<Void> = .init(from: [primary],
                hint: .replicated(set: setName))

            let update:Mongo.TopologyUpdateResult = topology.combine(
                update: .primary(.init(replica: filler, term: .init(
                        election: .init(0, 0, 0),
                        version: 2)),
                    peerlist),
                owner: Void.init(),
                host: primary)
            {
                _ in
            }

            tests.expect(update ==? .accepted)

            let ghosted:Mongo.TopologyUpdateResult = topology.combine(
                update: .primary(.init(replica: filler, term: .init(
                        election: .init(0, 0, 0),
                        version: 1)),
                    peerlist),
                owner: Void.init(),
                host: primary)
            {
                _ in
            }

            tests.expect(ghosted ==? .accepted)

            guard
            case .replicated(let replicated) = topology
            else
            {
                tests.expect(value: nil as Mongo.Topology<Void>.Replicated?)
                return
            }
            guard
            case .ghost? = replicated[primary]?.metadata
            else
            {
                tests.expect(true: false)
                return
            }
        }
    }
}
