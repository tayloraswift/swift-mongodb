extension Mongo
{
    class SessionManager
    {
        // TODO: implement time gossip
        private
        let cluster:Mongo.Cluster
        let id:Session.ID

        init(id:Session.ID, cluster:Mongo.Cluster)
        {
            self.cluster = cluster
            self.id = id
        }
        func extend(timeout:ContinuousClock.Instant)
        {
            Task.init
            {
                [id] in await self.cluster.extendSession(id, timeout: timeout)
            }
        }
        deinit
        {
            Task.init
            {
                [id, cluster] in await cluster.releaseSession(id)
            }
        }
    }
}
