extension Mongo
{
    struct HelloResult:Sendable
    {
        let response:HelloResponse
        let latency:Latency

        init(response:HelloResponse, latency:Latency)
        {
            self.response = response
            self.latency = latency
        }
    }
}
