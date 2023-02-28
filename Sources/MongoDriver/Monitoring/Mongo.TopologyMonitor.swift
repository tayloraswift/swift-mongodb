import Durations

extension Mongo
{
    struct TopologyMonitor:Sendable
    {
        private
        let connection:Connection
        private
        let consumer:AsyncThrowingStream<Update, any Error>.Continuation

        private
        let interval:Milliseconds,
            seed:Mongo.TopologyVersion

        init(_ consumer:AsyncThrowingStream<Update, any Error>.Continuation,
            connection:Connection,
            interval:Milliseconds,
            seed:Mongo.TopologyVersion)
        {
            self.connection = connection
            self.consumer = consumer
            self.interval = interval
            self.seed = seed
        }
    }
}
extension Mongo.TopologyMonitor
{
    func monitor() async
    {
        var version:Mongo.TopologyVersion = self.seed
        while true
        {
            do
            {
                let response:Mongo.HelloResponse = try await self.connection.run(
                    hello: .init(topologyVersion: version,
                        milliseconds: self.interval))
                
                version = response.topologyVersion
                
                self.consumer.yield(.init(
                    topology: response.topologyUpdate,
                    sessions: response.sessions,
                    canary: nil))
            }
            catch let error
            {
                self.consumer.finish(throwing: error)
                await self.connection.close()
                return
            }
        }
    }
}
