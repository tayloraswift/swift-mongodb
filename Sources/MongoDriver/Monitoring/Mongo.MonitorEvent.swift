import MongoClusters
import MongoLogging

extension Mongo
{
    @frozen public
    struct MonitorEvent<Type> where Type:Mongo.MonitorEventType
    {
        public
        let generation:UInt
        public
        let host:Host
        public
        let type:Type

        @inlinable public
        init(generation:UInt, host:Host, type:Type)
        {
            self.generation = generation
            self.host = host
            self.type = type
        }
    }
}
extension Mongo.MonitorEvent:Mongo.LogEvent
{
    @inlinable public
    var severity:Mongo.LogSeverity { self.type.severity }
}
extension Mongo.MonitorEvent:CustomStringConvertible
{
    public
    var description:String
    {
        "[\(self.host)(\(self.generation))] (\(Type.component)) \(self.type)"
    }
}
