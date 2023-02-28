import Durations
import NIOCore
import NIOPosix

extension Mongo
{
    struct Connector<Authenticator>
    {
        private
        let authenticator:Authenticator
        private
        let bootstrap:ClientBootstrap
        private
        let timeout:ConnectionTimeout
        private
        let appname:String?

        private
        let host:Host
        
        init(authenticator:Authenticator,
            bootstrap:ClientBootstrap,
            timeout:ConnectionTimeout,
            appname:String?,
            host:Host)
        {
            self.authenticator = authenticator
            self.bootstrap = bootstrap
            self.timeout = timeout
            self.appname = appname
            self.host = host
        }
    }
}
extension Mongo.Connector
{
    private
    var client:Mongo.Hello.ClientMetadata
    {
        .init(appname: self.appname)
    }

    private
    func channel() async throws -> any Channel
    {
        try await self.bootstrap.connect(host: self.host.name, port: self.host.port).get()
    }
}
extension Mongo.Connector<Never?>
{
    func monitors(interval:Milliseconds) async throws ->
    (
        producer:Mongo.MonitorTasks,
        updates:AsyncThrowingStream<Mongo.TopologyMonitor.Update, any Error>
    )
    {
        //  '''
        //  Drivers MUST NOT authenticate on sockets used for monitoring nor
        //  include SCRAM mechanism negotiation (i.e. saslSupportedMechs), as
        //  doing so would make monitoring checks more expensive for the server.
        //  '''
        let deadline:Mongo.ConnectionDeadline = self.timeout.deadline(from: .now)
        let hello:Mongo.Hello = .init(client: self.client, user: nil)

        let topology:Mongo.TopologyMonitor.Connection = .init(
            channel: try await self.channel())
        let latency:Mongo.LatencyMonitor.Connection

        async
        let handshake:Mongo.Handshake = topology.run(hello: hello, by: deadline)

        do
        {
            latency = .init(channel: try await self.channel())
        }
        catch let error
        {
            await topology.close()
            throw error
        }

        do
        {
            let handshake:Mongo.Handshake = try await handshake

            var consumer:AsyncThrowingStream<
                Mongo.TopologyMonitor.Update, any Error>.Continuation? = nil
            let updates:AsyncThrowingStream<
                Mongo.TopologyMonitor.Update, any Error> = .init
            {
                consumer = $0
            }
            return (.init(consumer: consumer!,
                topologyMonitorConnection: topology,
                latencyMonitorConnection: latency,
                handshake: handshake,
                interval: interval,
                host: self.host), updates)
        }
        catch let error
        {
            async
            let latency:Void = latency.close()

            await topology.close()
            await latency

            throw error
        }
    }
}
extension Mongo.Connector<Mongo.Authenticator>
{
    func connect(id:UInt) async throws -> Mongo.UnsafeConnection
    {
        let deadline:Mongo.ConnectionDeadline = self.timeout.deadline(
            from: .now)
        let connection:Mongo.UnsafeConnection = .init(
            channel: try await self.channel(),
            id: id)
        
        switch await self.authenticator.establish(connection,
            client: self.client,
            by: deadline)
        {
        case .success(_):
            return connection
        
        case .failure(let error):
            await connection.close()
            throw error
        }
    }
}
