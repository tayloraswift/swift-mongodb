extension Mongo
{
    @frozen public
    enum TopologyUpdateResult:Sendable
    {
        /// The update was incorporated into the topology. The initiator of the update should
        /// continue monitoring the relevant server, even if the purpose of the update was to
        /// invalidate the server.
        case accepted
        /// The update was not incorporated into the topology. This can happen synchronously,
        /// because it did not have a whitelisted host name, or asynchronously, because a
        /// concurrent task pruned the relevant server, and the pruning raced the update.
        /// In either case, the initiator of the update should stop monitoring the server.
        case rejected
        /// The update was not incorporated into the topology, because of an invalid state
        /// transition. This usually happens when a concurrent task tries to invalidate a
        /// server, and the invalidation raced a topology monitor update. The initiator of the
        /// update should continue monitoring the server.
        case dropped
    }
}
