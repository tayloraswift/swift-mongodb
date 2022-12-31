import MongoConnection

extension MongoTopology
{
    public
    struct Routers:Sendable
    {
        public private(set)
        var unreachables:[Rejection<Unreachable>]
        public private(set)
        var candidates:[Server<Router>]

        init(unreachables:[Rejection<Unreachable>] = [], candidates:[Server<Router>] = [])
        {
            self.unreachables = unreachables
            self.candidates = candidates
        }
    }
}
extension MongoTopology.Routers
{
    mutating
    func append(router:MongoConnection<MongoTopology.Router>.State, host:MongoTopology.Host)
    {
        switch router
        {
        case .connected(let connection):
            self.candidates.append(.init(connection: connection, host: host))
        
        case .errored(let error):
            self.unreachables.append(.init(reason: .errored(error), host: host))
        
        case .queued:
            self.unreachables.append(.init(reason: .queued, host: host))
        }
    }
}
