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

        //  initial login, performs auth (if using auth).
        //  this is not inside the `updating:` block, because we haven’t told
        //  the deployment about this connection, so it could not possibly
        //  throw us an ``EndSessions``.
        let initial:Mongo.Hello.Response = try await connection.establish(
            credentials: credentials)

        updating:
        do
        {
            var heartbeats:Heartbeat.AsyncIterator = heartbeat.makeAsyncIterator()
            var metadata:Mongo.ServerMetadata = initial.metadata
            while case ()? = await self.deployment?.update(host: host,
                connection: connection,
                metadata: metadata)
            {
                guard case ()? = try await heartbeats.next()
                else
                {
                    break updating
                }

                let updated:Mongo.Hello.Response = try await connection.run(
                    command: .init(user: nil))
                if  updated.token == initial.token
                {
                    metadata = updated.metadata
                }
                else
                {
                    throw Mongo.ConnectionTokenError.init(recorded: initial.token,
                        invalid: updated.token)
                }
            }
            // exhaust the iterator if we exited the loop above early
            // (due to `deinit` of `self.deployment`), because we want
            // to observe the ``EndSessions`` error if possible.
            while case ()? = try await heartbeats.next()
            {
            }
        }
        catch let command as Mongo.EndSessions
        {
            let response:Mongo.EndSessions.Response = try await connection.run(
                command: command)
            print(response)
        }
    }

    func monitor(_ host:Mongo.Host) async
    {
        monitoring:
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

            switch (self.deployment, status)
            {
            case (let deployment?, let status):
                //  deployment is alive. send the status update
                if case ()? = await deployment.clear(host: host, status: status)
                {
                    //  host remains known to the deployment.
                    continue monitoring
                }
                else
                {
                    //  host was removed.
                    break monitoring
                }
            
            case (nil, let error?):
                //  the deployment was deinitialized, but the connection
                //  monitor encountered an error.
                print(error)
                break monitoring
            
            case (nil, nil):
                break monitoring
            }
        }
    }
}
