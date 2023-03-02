extension Mongo
{
    public
    enum LoggingEvent
    {
        case sampler    (host:Host, generation:UInt, event:SamplerEvent)
        case listener   (host:Host, generation:UInt, event:ListenerEvent)
        case topology   (host:Host, generation:UInt, event:TopologyModelEvent)
        case pool       (host:Host, generation:UInt, event:ConnectionPoolEvent)
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
        var description:String
        switch self
        {
        case .sampler(host: let host, generation: let generation, event: let event):
            description = "[listener (\(host), \(generation))]: "
            switch event
            {
            case .sampled(let duration, metric: let metric):
                description += "sampled (\(duration), metric: \(metric))"
            
            case .errored(let error):
                description += "errored (\(error))"
            }
        
        case .listener(host: let host, generation: let generation, event: let event):
            description = "[listener (\(host), \(generation))]: "
            switch event
            {
            case .updated(let version):
                description += "updated (\(version))"
            
            case .errored(let error):
                description += "errored (\(error))"
            }
        
        case .topology(host: let host, generation: let generation, event: .removed):
            description = "[topology (\(host), \(generation))]: removed"

        case .pool(host: let host, generation: let generation, event: let event):
            description = "[connection pool (\(host), \(generation))]: "
            switch event
            {
            case .creating(_):
                description += "creating"
            
            case .draining(because: let error):
                description += "draining (\(error))"
            
            case .drained:
                description += "drained"

            case .expanding(id: let id):
                description += "expanding (\(id))"
            
            case .expanded(id: let id):
                description += "expanded (\(id))"
            
            case .perished(id: let id, because: _):
                description += "perished (\(id))"
            
            case .removed(id: let id):
                description += "removed (\(id))"

            case .creatingConnection:
                break
            case .createdConnection:
                break
            case .destroyedConnection:
                break
            }
        }
        return description
    }
}

