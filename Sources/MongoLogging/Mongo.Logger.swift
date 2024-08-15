import Atomics

extension Mongo
{
    /// A `Logger` instance is a handle to some ``Mongo.LogTarget`` with a thread-safe
    /// interface for dynamically configuring the logging level. This enables logging targets
    /// to not have to worry about filtering events.
    public final
    class Logger:Sendable
    {
        let target:any Mongo.LogTarget
        private
        let state:UnsafeAtomic<LogSeverity>

        public
        init(target:any Mongo.LogTarget = Mongo.PrettyPrint.init(),
            level:LogSeverity = .error)
        {
            self.target = target
            self.state = .create(level)
        }

        deinit
        {
            self.state.destroy()
        }
    }
}
extension Mongo.Logger
{
    /// Configures the logging level. A ``Mongo.LogSeverity/fatal`` level disables logging
    /// entirely.
    ///
    /// This function doesn’t suspend, because `Logger` instances track their logging levels
    /// with atomic primitives. However this type does have mutable reference semantics, and can
    /// have its state changed from many concurrent contexts. Therefore there is no guarantee
    /// that the logging level read from ``level`` will be the same as the level that was just
    /// configured.
    public
    func configure(level:Mongo.LogSeverity)
    {
        self.state.store(level, ordering: .relaxed)
    }
    public
    var level:Mongo.LogSeverity
    {
        self.state.load(ordering: .relaxed)
    }
}
extension Mongo.Logger
{
    public
    func yield(event:some Mongo.LogEvent)
    {
        if  self.level <= event.severity
        {
            self.target.log(event: event)
        }
    }
}
