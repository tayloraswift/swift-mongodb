extension Mongo
{
    /// A type that monitoring services use to communicate to a monitoring task.
    struct MonitorDelegate
    {
        private
        let continuation:AsyncStream<MonitorService>.Continuation

        init(_ continuation:AsyncStream<MonitorService>.Continuation)
        {
            self.continuation = continuation
        }
    }
}
extension Mongo.MonitorDelegate
{
    func resume(from service:Mongo.MonitorService)
    {
        self.continuation.yield(service)
    }
}
