import Heartbeats

extension Mongo
{
    struct ConnectionMonitor
    {
        private
        weak var deployment:Mongo.Deployment?

        init(_ deployment:__shared Mongo.Deployment)
        {
            self.deployment = deployment
        }
    }
}
extension Mongo.ConnectionMonitor
{    
    private
    func connect(to host:Mongo.Host) async throws
    {
        let credentials:Mongo.Credentials?
        let connection:Mongo.Connection
        let heartbeat:Heartbeat

        if let deployment:Mongo.Deployment = self.deployment
        {
            heartbeat = .init(interval: .milliseconds(1000))
            connection = try await deployment.connect(to: host, heart: heartbeat.heart)
            credentials = deployment.credentials
        }
        else
        {
            // client has been deinitialized.
            return
        }
        
        defer
        {
            // will be a no-op if the connection closed spontaneously,
            // terminating the stream of heartbeats
            connection.close()
        }

        // initial login, performs auth (if using auth)
        let metadata:Mongo.ServerMetadata = try await connection.establish(
            credentials: credentials)
        let token:Mongo.ConnectionToken = metadata.token
        
        guard case ()? = await self.deployment?.update(host: host,
            connection: connection,
            metadata: metadata.type)
        else
        {
            return
        }
        for try await _:Void in heartbeat
        {
            let metadata:Mongo.ServerMetadata = try await connection.run(
                command: .init(user: nil))
            
            guard metadata.token == token
            else
            {
                throw Mongo.ConnectionTokenError.init(recorded: token,
                    invalid: metadata.token)
            }
            
            guard case ()? = await self.deployment?.update(host: host,
                connection: connection,
                metadata: metadata.type)
            else
            {
                break
            }
        }
    }

    func monitor(_ host:Mongo.Host) async
    {
        while true
        {
            let status:(any Error)?

            do
            {
                try await self.connect(to: host)
                status = nil
            }
            catch let error
            {
                status = error
            }

            //  only continue monitoring if the deployment is alive,
            //  and the host remains known to it.
            guard case ()? = await self.deployment?.clear(host: host, status: status)
            else
            {
                break
            }
        }
    }
}
