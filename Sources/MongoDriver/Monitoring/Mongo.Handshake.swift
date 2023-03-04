import Durations

extension Mongo
{
    struct Handshake:Sendable
    {
        let response:HelloResponse
        let latency:Nanoseconds

        init(response:HelloResponse, latency:Nanoseconds)
        {
            self.response = response
            self.latency = latency
        }
    }
}
