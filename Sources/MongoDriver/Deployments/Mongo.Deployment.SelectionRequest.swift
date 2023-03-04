extension Mongo.Deployment
{
    typealias SelectionResponse =
        Result<Mongo.ConnectionPool, Mongo.DeploymentStateError<Mongo.ReadPreferenceError>>
}
extension Mongo.Deployment
{
    struct SelectionRequest
    {
        let preference:Mongo.ReadPreference
        let promise:CheckedContinuation<SelectionResponse, Never>

        init(preference:Mongo.ReadPreference,
            promise:CheckedContinuation<SelectionResponse, Never>)
        {
            self.preference = preference
            self.promise = promise
        }
    }
}
extension Mongo.Deployment.SelectionRequest?
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
            diagnostics: request.preference.diagnose(servers: servers),
            failure: .init(preference: request.preference))))
    }
    mutating
    func fulfill(with pool:Mongo.ConnectionPool)
    {
        if  let request:Wrapped = self
        {
            request.promise.resume(returning: .success(pool))
            self = nil
        }
    }
}
