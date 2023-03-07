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
        let timeout:Milliseconds
        private
        let appname:String?

        private
        let host:Host
        
        init(authenticator:Authenticator,
            bootstrap:ClientBootstrap,
            timeout:Milliseconds,
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
    func connect(interval:Milliseconds) async throws -> Mongo.MonitorServices
    {
        //  '''
        //  Drivers MUST NOT authenticate on sockets used for monitoring nor
        //  include SCRAM mechanism negotiation (i.e. saslSupportedMechs), as
        //  doing so would make monitoring checks more expensive for the server.
        //  '''
        let deadline:ContinuousClock.Instant = .now.advanced(by: .milliseconds(self.timeout))
        let hello:Mongo.Hello = .init(client: self.client, user: nil)

        let listener:Mongo.Listener.Connection = .init(
            channel: try await self.channel())
        let sampler:Mongo.Sampler.Connection

        async
        let handshake:Mongo.Handshake = listener.run(hello: hello, by: deadline)

        do
        {
            sampler = .init(channel: try await self.channel())
        }
        catch let error
        {
            await listener.close()
            throw error
        }

        do
        {
            return .init(listenerConnection: listener,
                samplerConnection: sampler,
                handshake: try await handshake,
                interval: interval)
        }
        catch let error
        {
            async
            let sampler:Void = sampler.close()

            await listener.close()
            await sampler

            throw error
        }
    }
}
extension Mongo.Connector<Mongo.Authenticator>
{
    func connect(id:UInt) async throws -> Mongo.ConnectionPool.Allocation
    {
        let deadline:ContinuousClock.Instant = .now.advanced(
            by: .milliseconds(self.timeout))
        let connection:Mongo.ConnectionPool.Allocation = .init(
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
