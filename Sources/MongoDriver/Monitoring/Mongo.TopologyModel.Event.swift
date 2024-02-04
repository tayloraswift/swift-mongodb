import MongoLogging

extension Mongo.TopologyModel
{
    public
    enum Event:Sendable
    {
        case removed
    }
}
extension Mongo.TopologyModel.Event:Mongo.MonitorEventType
{
    @inlinable public static
    var component:Mongo.MonitorService { .topology }

    @inlinable public
    var severity:Mongo.LogSeverity { .debug }
}
extension Mongo.TopologyModel.Event:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .removed: "removed"
        }
    }
}
