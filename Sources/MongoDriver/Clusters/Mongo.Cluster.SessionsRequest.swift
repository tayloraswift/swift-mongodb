extension Mongo.Cluster
{
    typealias SessionsResponse =
        Result<Mongo.LogicalSessions, Mongo.ClusterError<Mongo.LogicalSessionsError>>
}
extension Mongo.Cluster
{
    struct SessionsRequest
    {
        let promise:CheckedContinuation<SessionsResponse, Never>

        init(promise:CheckedContinuation<SessionsResponse, Never>)
        {
            self.promise = promise
        }
    }
}
extension Mongo.Cluster.SessionsRequest?
{
    mutating
    func fail(diagnosing servers:Mongo.Servers)
    {
        guard let request:Mongo.Cluster.SessionsRequest = self
        else
        {
            return
        }
        defer
        {
            self = nil
        }

        request.promise.resume(returning: .failure(.init(
            diagnostics: .init(unreachable: servers.unreachable),
            failure: .init())))
    }
    mutating
    func fulfill(with sessions:Mongo.LogicalSessions)
    {
        if  let request:Mongo.Cluster.SessionsRequest = self
        {
            request.promise.resume(returning: .success(sessions))
            self = nil
        }
    }
}
