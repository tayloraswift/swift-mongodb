import MongoLogging

extension Mongo
{
    public
    protocol MonitorEventType:Sendable
    {
        static
        var component:MonitorService { get }
        var severity:LogSeverity { get }
    }
}
