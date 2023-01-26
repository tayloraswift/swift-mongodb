extension Mongo.Cluster
{
    typealias SelectionResponse =
        Result<Mongo.ConnectionPool, Mongo.ClusterError<Mongo.ReadPreferenceError>>
}
extension Mongo.Cluster
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
extension Mongo.Cluster.SelectionRequest?
{
    mutating
    func fail(diagnosing servers:Mongo.Servers)
    {
        guard let request:Mongo.Cluster.SelectionRequest = self
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
        if  let request:Mongo.Cluster.SelectionRequest = self
        {
            request.promise.resume(returning: .success(pool))
            self = nil
        }
    }
}
