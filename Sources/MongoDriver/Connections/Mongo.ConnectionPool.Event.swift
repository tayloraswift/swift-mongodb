import MongoLogging

extension Mongo.ConnectionPool
{
    @frozen public
    enum Event:Sendable
    {
        case creating(Mongo.ConnectionPoolSettings)
        case draining(because:any Error)
        case drained

        case expanding(id:UInt)
        case expanded(id:UInt)
        case perished(id:UInt, because:Result<Void, any Error>)
        case removed(id:UInt)

        case creatingConnection
        case createdConnection
        case destroyedConnection
    }
}
extension Mongo.ConnectionPool.Event:Mongo.MonitorEventType
{
    @inlinable public static
    var component:Mongo.MonitorService { .pool }

    @inlinable public
    var severity:Mongo.LogSeverity
    {
        switch self
        {
        case .creating:                         .debug
        case .draining:                         .error
        case .drained:                          .debug
        case .expanding:                        .debug
        case .expanded:                         .debug
        case .perished(_, because: .failure):   .error
        case .perished(_, because: .success):   .debug
        case .removed:                          .debug
        case .creatingConnection:               .debug
        case .createdConnection:                .debug
        case .destroyedConnection:              .debug
        }
    }
}
extension Mongo.ConnectionPool.Event:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .creating(let settings):
            "creating (\(settings))"

        case .draining(because: let error):
            "draining (\(error))"

        case .drained:
            "drained"

        case .expanding(id: let id):
            "expanding (\(id))"

        case .expanded(id: let id):
            "expanded (\(id))"

        case .perished(id: let id, because: .failure(let error)):
            "perished (\(id), error: \(error))"

        case .perished(id: let id, because: .success):
            "perished (\(id))"

        case .removed(id: let id):
            "removed (\(id))"

        case .creatingConnection:
            "creating connection"

        case .createdConnection:
            "created connection"

        case .destroyedConnection:
            "destroyed connection"
        }
    }
}
