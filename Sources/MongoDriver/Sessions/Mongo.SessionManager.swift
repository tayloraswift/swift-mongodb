extension Mongo
{
    class SessionManager
    {
        // TODO: implement time gossip
        private
        let deployment:Mongo.Deployment
        var metadata:SessionMetadata

        init(metadata:SessionMetadata, deployment:Mongo.Deployment)
        {
            self.deployment = deployment
            self.metadata = metadata
        }
        deinit
        {
            Task.init
            {
                [metadata, deployment] in await deployment.checkin(session: metadata)
            }
        }
    }
}
