import MongoClusters
import Testing

@Suite
struct ReplicaSets
{
    final
    class Void
    {
        init() {}
    }

    private
    var localhost:Mongo.Host { .init(name: "localhost") }
    private
    var secondary:Mongo.Host { .init(name: "secondary") }
    private
    var primary:Mongo.Host { .init(name: "primary") }
    private
    var setName:String { "example-rs" }

    /// Mocked peerlist.
    private
    var peerlist:Mongo.Peerlist
    {
        .init(set: self.setName,
            primary: self.primary,
            arbiters: [],
            passives: [],
            hosts: [self.primary, self.secondary],
            me: self.primary)
    }

    /// Mocked replica metadata.
    private
    var filler:Mongo.Replica
    {
        .init(capabilities: .init(
                logicalSessionTimeoutMinutes: 1,
                maxWriteBatchCount: 1,
                maxDocumentSize: 1,
                maxMessageSize: 1),
            timings: .init(write: .zero),
            tags: [:])
    }

    @Test
    func PrimaryRenameWithoutHint() throws
    {
        var topology:Mongo.Topology<Void> = .init(from: [self.localhost], hint: nil)
        let update:Mongo.TopologyUpdateResult = topology.combine(
            update: .primary(.init(replica: filler, term: .init(
                    election: .init(0, 0, 0),
                    version: 1)),
                peerlist),
            owner: Void.init(),
            host: self.localhost)
        {
            _ in
        }

        #expect(update == .rejected)

        guard
        case .replicated(let replicated) = topology
        else
        {
            Issue.record()
            return
        }
        guard
        case .queued? = replicated[self.primary]
        else
        {
            Issue.record()
            return
        }
    }

    @Test
    func PrimaryRenameWithHint() throws
    {
        var topology:Mongo.Topology<Void> = .init(from: [self.localhost],
            hint: .replicated(set: self.setName))

        let update:Mongo.TopologyUpdateResult = topology.combine(
            update: .primary(.init(replica: filler, term: .init(
                    election: .init(0, 0, 0),
                    version: 1)),
                peerlist),
            owner: Void.init(),
            host: self.localhost)
        {
            _ in
        }

        #expect(update == .rejected)

        guard
        case .replicated(let replicated) = topology
        else
        {
            Issue.record()
            return
        }
        guard
        case .queued? = replicated[self.primary]
        else
        {
            Issue.record()
            return
        }
    }

    @Test
    func GHOSTED() throws
    {
        var topology:Mongo.Topology<Void> = .init(from: [self.primary],
            hint: .replicated(set: self.setName))

        let update:Mongo.TopologyUpdateResult = topology.combine(
            update: .primary(.init(replica: filler, term: .init(
                    election: .init(0, 0, 0),
                    version: 2)),
                peerlist),
            owner: Void.init(),
            host: self.primary)
        {
            _ in
        }

        #expect(update == .accepted)

        let ghosted:Mongo.TopologyUpdateResult = topology.combine(
            update: .primary(.init(replica: filler, term: .init(
                    election: .init(0, 0, 0),
                    version: 1)),
                peerlist),
            owner: Void.init(),
            host: self.primary)
        {
            _ in
        }

        #expect(ghosted == .accepted)

        guard
        case .replicated(let replicated) = topology
        else
        {
            Issue.record()
            return
        }
        guard
        case .ghost? = replicated[self.primary]?.metadata
        else
        {
            Issue.record()
            return
        }
    }
}
