/// TODO: do we really need this?
protocol _MongoConcurrencyDomain:Identifiable<Mongo.SessionIdentifier>
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
