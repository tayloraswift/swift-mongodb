protocol MongoSessionType
{
    static
    var medium:Mongo.SessionMediumSelector { get }

    init(monitor:Mongo.TopologyMonitor,
        context:Mongo.SessionContext,
        medium:Mongo.SessionMedium)

    var context:Mongo.SessionContext { get }
}
