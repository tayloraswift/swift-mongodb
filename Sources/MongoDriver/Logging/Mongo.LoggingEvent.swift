extension Mongo
{
    public
    enum LoggingEvent
    {
        case pool(host:Host, generation:UInt, event:ConnectionPool.Event)
    }
}
extension Mongo.LoggingEvent
{
}
extension Mongo.LoggingEvent:CustomStringConvertible
{
    public
    var description:String
    {
        var description:String = ""
        switch self
        {
        case .pool(host: let host, generation: let generation, event: let event):
            description +=
            """
                pool: \(host) (generation: \(generation))
                
            """
            switch event
            {
            case .creating(_):
                description +=
                """
                type: creating
                """
            case .draining:
                description +=
                """
                type: draining
                """
            case .drained:
                description +=
                """
                type: drained
                """

            case .expanding(id: let id):
                description +=
                """
                type: expanding (id: \(id))
                """
            case .expanded(id: let id):
                description +=
                """
                type: expanded (id: \(id))
                """
            case .perished(id: let id, because: _):
                description +=
                """
                type: perished (id: \(id))
                """
            case .removed(id: let id):
                description +=
                """
                type: removed (id: \(id))
                """

            case .creatingConnection:
                break
            case .createdConnection:
                break
            case .destroyedConnection:
                break
            }
        }
        return "{\n\(description)\n}"
    }
}

