import MongoChannel
import NIOCore
import NIOPosix
import NIOSSL

extension Mongo
{
    struct ConnectionBootstrap
    {
        let channel:ClientBootstrap
        let _credentials:Credentials?,
            _appname:String?
        let host:Mongo.Host
        
        private
        init(channel:ClientBootstrap,
            _credentials:Credentials?,
            _appname:String?,
            host:Mongo.Host)
        {
            self.channel = channel
            self._credentials = _credentials
            self._appname = _appname
            self.host = host
        }
    }
}
extension Mongo.ConnectionBootstrap
{
    init(from bootstrap:__shared Mongo.DriverBootstrap, host:Mongo.Host)
    {
        self.init(channel: bootstrap.bootstrap(for: host),
            _credentials: bootstrap.credentials,
            _appname: bootstrap.appname,
            host: host)
    }
}
extension Mongo.ConnectionBootstrap
{
    func channel(to host:Mongo.Host) async throws -> MongoChannel
    {
        let channel:MongoChannel = .init(try await self.channel.connect(
            host: host.name,
            port: host.port).get())
        
        switch await channel.establish(credentials: self._credentials, appname: self._appname)
        {
        case .success(_):
            return channel
        
        case .failure(let error):
            await channel.close()
            throw error
        }
    }
}
