import MongoTopology

extension Mongo.Cluster
{
    struct SessionsRequest
    {
        let promise:CheckedContinuation<Mongo.LogicalSessions, any Error>

        init(promise:CheckedContinuation<Mongo.LogicalSessions, any Error>)
        {
            self.promise = promise
        }
    }
}
extension Mongo.Cluster.SessionsRequest?
{
    mutating
    func fail(diagnosing servers:MongoTopology.Servers)
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

        request.promise.resume(throwing: Mongo.ClusterError<Mongo.LogicalSessionsError>.init(
            diagnostics: .init(unreachable: servers.unreachable),
            failure: .init()))
    }
    mutating
    func fulfill(with sessions:Mongo.LogicalSessions)
    {
        if  let request:Mongo.Cluster.SessionsRequest = self
        {
            request.promise.resume(returning: sessions)
            self = nil
        }
    }
}
