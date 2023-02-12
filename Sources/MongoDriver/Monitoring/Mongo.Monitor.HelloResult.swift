extension Mongo.Monitor
{
    struct HelloResult:Sendable
    {
        let response:HelloResponse
        let latency:Mongo.Latency

        init(response:HelloResponse, latency:Duration)
        {
            self.response = response
            self.latency = .init(latency)
        }
    }
}
