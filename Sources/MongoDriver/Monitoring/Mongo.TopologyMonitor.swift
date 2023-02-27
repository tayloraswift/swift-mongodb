import Durations

extension Mongo
{
    struct TopologyMonitor:Sendable
    {
        private
        let connection:Connection
        private
        let consumer:AsyncThrowingStream<Update, any Error>.Continuation

        init(_ consumer:AsyncThrowingStream<Update, any Error>.Continuation,
            connection:Connection)
        {
            self.connection = connection
            self.consumer = consumer
        }
    }
}
extension Mongo.TopologyMonitor
{
    func monitor(every interval:Milliseconds, seed:Mongo.TopologyVersion) async
    {
        var version:Mongo.TopologyVersion = seed
        while true
        {
            do
            {
                let response:Mongo.HelloResponse = try await self.connection.run(
                    hello: .init(topologyVersion: version,
                        milliseconds: interval))
                
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
