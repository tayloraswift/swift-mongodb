public
protocol MongoLoggingTarget:Sendable
{
    func log(level:Mongo.LoggingLevel, event:Mongo.LoggingEvent)
}
