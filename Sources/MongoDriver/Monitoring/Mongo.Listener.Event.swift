import MongoLogging

extension Mongo.Listener
{
    public
    enum Event:Sendable
    {
        case updated(Mongo.TopologyVersion)
        case errored(any Error)
    }
}
extension Mongo.Listener.Event:Mongo.MonitorEventType
{
    @inlinable public static
    var component:Mongo.MonitorService { .listener }

    @inlinable public
    var severity:Mongo.LogSeverity
    {
        switch self
        {
        case .updated:  .debug
        case .errored:  .error
        }
    }
}
extension Mongo.Listener.Event:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .updated(let version): "updated (\(version))"
        case .errored(let error):   "errored (\(error))"
        }
    }
}
