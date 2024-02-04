import MongoLogging

extension Mongo
{
    public
    typealias MonitorEventType = _MongoMonitorEventType
}
/// The name of this protocol is ``Mongo.MonitorEventType``.
public
protocol _MongoMonitorEventType:Sendable
{
    static
    var component:Mongo.MonitorService { get }
    var severity:Mongo.LogSeverity { get }
}
