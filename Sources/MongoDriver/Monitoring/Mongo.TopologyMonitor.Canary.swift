extension Mongo.TopologyMonitor
{
    final
    class Canary:Sendable
    {
        private
        let caller:AsyncThrowingStream<Update, any Error>.Continuation
        let pool:Mongo.ConnectionPool

        init(_ caller:AsyncThrowingStream<Update, any Error>.Continuation,
            pool:Mongo.ConnectionPool)
        {
            self.caller = caller
            self.pool = pool
        }

        deinit
        {
            caller.finish()
        }
    }
}
