import MongoTopology

extension Mongo.Cluster
{
    struct MediumRequest
    {
        let preference:Mongo.ReadPreference
        let promise:CheckedContinuation<Mongo.ReadMedium, any Error>

        init(preference:Mongo.ReadPreference,
            promise:CheckedContinuation<Mongo.ReadMedium, any Error>)
        {
            self.preference = preference
            self.promise = promise
        }
    }
}
extension Mongo.Cluster.MediumRequest?
{
    mutating
    func fail(diagnosing servers:MongoTopology.Servers)
    {
        guard let request:Mongo.Cluster.MediumRequest = self
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
    func fulfill(with connection:Mongo.ReadMedium)
    {
        if  let request:Mongo.Cluster.MediumRequest = self
        {
            request.promise.resume(returning: connection)
            self = nil
        }
    }
}
