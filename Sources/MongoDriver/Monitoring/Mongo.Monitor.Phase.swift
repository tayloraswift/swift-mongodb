extension Mongo.Monitor
{
    enum Phase
    {
        case active(State)
        case stopping(CheckedContinuation<Void, Never>)
        case stopped
    }
}
