extension Mongo
{
    public
    typealias LogTarget = _MongoLogTarget
}

/// The name of this protocol is ``Mongo.LogTarget``.
public
protocol _MongoLogTarget:Sendable
{
    func log(event:some Mongo.LogEvent)
}
