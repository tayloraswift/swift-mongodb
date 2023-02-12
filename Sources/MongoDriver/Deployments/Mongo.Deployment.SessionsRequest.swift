extension Mongo.Deployment
{
    typealias SessionsResponse =
        Result<Mongo.LogicalSessions, Mongo.DeploymentStateError<Mongo.LogicalSessionsError>>
}
extension Mongo.Deployment
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
extension Mongo.Deployment.SessionsRequest?
{
    mutating
    func fail(diagnosing servers:Mongo.Servers)
    {
        guard let request:Wrapped = self
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
        if  let request:Wrapped = self
        {
            request.promise.resume(returning: .success(sessions))
            self = nil
        }
    }
}
