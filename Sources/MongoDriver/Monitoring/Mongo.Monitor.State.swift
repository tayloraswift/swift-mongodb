extension Mongo.Monitor
{
    enum State
    {
        case monitoring(Mongo.ConnectionPool.Bootstrap, Mongo.Topology<Mongo.ConnectionPool>)
        case stopping(CheckedContinuation<Void, Never>?)
    }
}
