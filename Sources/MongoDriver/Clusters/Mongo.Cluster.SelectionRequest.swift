extension Mongo.Cluster
{
    struct SelectionRequest
    {
        let preference:Mongo.ReadPreference
        let promise:CheckedContinuation<Mongo.ConnectionPool, any Error>

        init(preference:Mongo.ReadPreference,
            promise:CheckedContinuation<Mongo.ConnectionPool, any Error>)
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
        
        request.promise.resume(throwing: Mongo.ClusterError<Mongo.ReadPreferenceError>.init(
            diagnostics: request.preference.diagnose(servers: servers),
            failure: .init(preference: request.preference)))
    }
    mutating
    func fulfill(with pool:Mongo.ConnectionPool)
    {
        if  let request:Mongo.Cluster.SelectionRequest = self
        {
            request.promise.resume(returning: pool)
            self = nil
        }
    }
}
