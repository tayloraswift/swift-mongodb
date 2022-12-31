/// TODO: do we really need this?
protocol _MongoConcurrencyDomain:Identifiable<Mongo.SessionIdentifier>
{
    init(monitor:Mongo.Monitor,
        connectionTimeout:Duration,
        metadata:Mongo.SessionMetadata,
        id:Mongo.SessionIdentifier)
    
    var monitor:Mongo.Monitor { get }
    var metadata:Mongo.SessionMetadata { get }
    var id:Mongo.SessionIdentifier { get }
}
