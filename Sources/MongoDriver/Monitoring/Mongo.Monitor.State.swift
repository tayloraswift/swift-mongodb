extension Mongo.Monitor
{
    enum State
    {
        case monitoring(Mongo.MonitorConnector, Mongo.Topology<Mongo.MonitorTask>)
        case stopping(CheckedContinuation<Void, Never>?)
    }
}
