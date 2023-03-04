extension Mongo
{
    public
    enum ListenerEvent:Sendable
    {
        case updated(TopologyVersion)
        case errored(any Error)
    }
}
