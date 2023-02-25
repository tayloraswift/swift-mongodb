import Durations

extension Mongo
{
    struct TopologyMonitor:Sendable
    {
        private
        let connection:Connection
        private
        let consumer:AsyncStream<MonitorUpdate>.Continuation

        init(_ consumer:AsyncStream<MonitorUpdate>.Continuation,
            using connection:Connection)
        {
            self.connection = connection
            self.consumer = consumer
        }
    }
}
extension Mongo.TopologyMonitor
{
    func stop()
    {
        self.connection.interrupt()
    }
    func monitor() async
    {
        defer
        {
            self.consumer.finish()
        }
        while true
        {
            do
            {
                let response:Mongo.HelloResponse = try await self.connection.listen(
                    granularity: .milliseconds(1000))
                
                self.consumer.yield(.topology(.success(.init(topology: response.update,
                    sessions: response.sessions,
                    owner: nil))))
            }
            catch let error
            {
                self.consumer.yield(.topology(.failure(error)))
                return
            }
        }
    }
}
