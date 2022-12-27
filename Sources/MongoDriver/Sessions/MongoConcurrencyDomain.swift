protocol MongoConcurrencyDomain:Identifiable<Mongo.SessionIdentifier>
{
    static
    var medium:Mongo.SessionMediumSelector { get }

    init(monitor:Mongo.Monitor,
        metadata:Mongo.SessionMetadata,
        medium:Mongo.SessionMedium,
        id:Mongo.SessionIdentifier)
    
    var monitor:Mongo.Monitor { get }
    var metadata:Mongo.SessionMetadata { get }
    var id:Mongo.SessionIdentifier { get }
}
extension MongoConcurrencyDomain
{
    var _time:UInt64?
    {
        let time:UInt64 = self.monitor.time.load(ordering: .relaxed)
        return time == 0 ? nil : time
    }
}
