extension Mongo
{
    public
    typealias LoggingTarget = _MongoLoggingTarget
}

/// The name of this protocol is ``Mongo.LoggingTarget``.
public
protocol _MongoLoggingTarget:Sendable
{
    func log(level:Mongo.LoggingLevel, event:Mongo.LoggingEvent)
}
