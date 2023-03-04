extension Mongo.Deployment
{
    typealias CapabilityResponse = Result<Mongo.DeploymentCapabilities,
        Mongo.DeploymentStateError<Mongo.SessionsUnsupportedError>>
}
extension Mongo.Deployment
{
    struct CapabilityRequest
    {
        let promise:CheckedContinuation<CapabilityResponse, Never>

        init(promise:CheckedContinuation<CapabilityResponse, Never>)
        {
            self.promise = promise
        }
    }
}
extension Mongo.Deployment.CapabilityRequest?
{
    mutating
    func fail(diagnosing servers:Mongo.ServerTable)
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
    func fulfill(with capabilities:Mongo.DeploymentCapabilities)
    {
        if  let request:Wrapped = self
        {
            request.promise.resume(returning: .success(capabilities))
            self = nil
        }
    }
}
