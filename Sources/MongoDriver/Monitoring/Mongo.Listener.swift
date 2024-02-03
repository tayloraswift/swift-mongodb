import Durations

extension Mongo
{
    struct Listener:Sendable
    {
        private
        let connection:Connection

        private
        let interval:Milliseconds,
            seed:TopologyVersion

        init(connection:Connection,
            interval:Milliseconds,
            seed:TopologyVersion)
        {
            self.connection = connection
            self.interval = interval
            self.seed = seed
        }
    }
}
extension Mongo.Listener
{
    func start(alongside pool:Mongo.ConnectionPool,
        updating stream:AsyncThrowingStream<Mongo.MonitorPool.Update, any Error>.Continuation)
        async
    {
        var version:Mongo.TopologyVersion = self.seed
        do
        {
            while true
            {
                let response:Mongo.HelloResponse = try await self.connection.run(
                    hello: .init(topologyVersion: version, milliseconds: self.interval))

                version = response.topologyVersion

                pool.log(listenerEvent: .updated(version))

                stream.yield(.init(topology: response.topologyUpdate))
            }
        }
        catch let error
        {
            pool.monitor.resume(from: .listener)
            pool.log(listenerEvent: .errored(error))

            stream.finish(throwing: error)
            await self.connection.close()
        }
    }
}
