import Atomics

extension Mongo
{
    public final
    class Logger:Sendable
    {
        let target:any Mongo.LoggingTarget
        private
        let state:UnsafeAtomic<UInt8>

        public
        init(target:any Mongo.LoggingTarget = Mongo.PrettyPrint.init(),
            level:LoggingLevel?)
        {
            self.target = target
            self.state = .create(level?.rawValue ?? 0)
        }

        deinit
        {
            self.state.destroy()
        }
    }
}
extension Mongo.Logger
{
    /// Configures the logging level. A nil level disables logging entirely.
    ///
    /// This function doesn’t suspend, because `Logger` instances track their
    /// logging levels with atomic primitives. However this type does have
    /// mutable reference semantics, and can have its state changed from many
    /// concurrent contexts. Therefore there is no guarantee that the logging
    /// level read from ``level`` will be the same as the level that was just
    /// configured.
    public
    func configure(level:Mongo.LoggingLevel?)
    {
        self.state.store(level?.rawValue ?? 0, ordering: .relaxed)
    }
    public
    var level:Mongo.LoggingLevel?
    {
        .init(rawValue: self.state.load(ordering: .relaxed))
    }
}
extension Mongo.Logger
{
    func yield(level:Mongo.LoggingLevel, event:Mongo.LoggingEvent)
    {
        if  let threshold:Mongo.LoggingLevel = self.level,
                threshold <= level
        {
            self.target.log(level: level, event: event)
        }
    }
}
