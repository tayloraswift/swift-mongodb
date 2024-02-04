extension Mongo
{
    public
    typealias LogEvent = _MongoLogEvent
}
/// The name of this protocol is ``Mongo.LogEvent``.
public
protocol _MongoLogEvent:Sendable
{
    var severity:Mongo.LogSeverity { get }
}
