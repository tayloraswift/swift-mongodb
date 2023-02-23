extension Mongo.Monitor
{
    enum State
    {
        case monitoring(Mongo.MonitorConnector, Mongo.Topology<Mongo.ConnectionPool>)
        case stopping(CheckedContinuation<Void, Never>?)
    }
}
