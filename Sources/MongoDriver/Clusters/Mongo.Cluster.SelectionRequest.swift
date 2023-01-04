import MongoChannel
import MongoTopology

extension Mongo.Cluster
{
    struct SelectionRequest
    {
        let preference:Mongo.ReadPreference
        let promise:CheckedContinuation<MongoChannel, any Error>

        init(preference:Mongo.ReadPreference,
            promise:CheckedContinuation<MongoChannel, any Error>)
        {
            self.preference = preference
            self.promise = promise
        }
    }
}
extension Mongo.Cluster.SelectionRequest?
{
    mutating
    func fail(diagnosing servers:MongoTopology.Servers)
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
            diagnostics: request.preference.diagnose(unsuitable: servers),
            failure: .init(preference: request.preference)))
    }
    mutating
    func fulfill(with channel:MongoChannel)
    {
        if  let request:Mongo.Cluster.SelectionRequest = self
        {
            request.promise.resume(returning: channel)
            self = nil
        }
    }
}
