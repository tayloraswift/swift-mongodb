extension Mongo
{
    final
    class MonitorTask
    {
        private
        let caller:AsyncStream<MonitorUpdate>.Continuation

        init(_ caller:AsyncStream<MonitorUpdate>.Continuation)
        {
            self.caller = caller
        }

        deinit
        {
            caller.finish()
        }
    }
}
