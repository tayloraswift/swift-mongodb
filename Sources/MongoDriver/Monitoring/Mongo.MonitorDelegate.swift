extension Mongo
{
    /// A type that monitoring services use to communicate to a monitoring task.
    struct MonitorDelegate
    {
        private
        let continuation:AsyncStream<Service>.Continuation

        init(_ continuation:AsyncStream<Service>.Continuation)
        {
            self.continuation = continuation
        }
    }
}
extension Mongo.MonitorDelegate
{
    func resume(from service:Mongo.Service)
    {
        self.continuation.yield(service)
    }
}
