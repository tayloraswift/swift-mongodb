import MongoChannel
import MongoConnection

extension MongoTopology
{
    public
    struct Replicas:Sendable
    {
        public
        var unreachables:[Rejection<Unreachable>]
        public
        var undesirables:[Rejection<Undesirable>]
        public
        var secondaries:[Server<Replica>]
        public
        var primary:Server<Replica>?

        init(unreachables:[Rejection<Unreachable>] = [],
            undesirables:[Rejection<Undesirable>] = [],
            secondaries:[Server<Replica>] = [],
            primary:Server<Replica>? = nil)
        {
            self.unreachables = unreachables
            self.undesirables = undesirables
            self.secondaries = secondaries
            self.primary = primary
        }
    }
}
extension MongoTopology.Replicas
{
    mutating
    func append(member:MongoConnection<MongoTopology.Member?>.State, host:MongoTopology.Host)
    {
        switch member
        {
        case .connected(let connection):
            self.append(member: connection, host: host)
        
        case .errored(let error):
            self.unreachables.append(.init(reason: .errored(error), host: host))
        
        case .queued:
            self.unreachables.append(.init(reason: .queued, host: host))
        }
    }
    private mutating
    func append(member:MongoConnection<MongoTopology.Member?>, host:MongoTopology.Host)
    {
        switch member.metadata
        {
        case .primary(let metadata)?:
            self.primary = .init(
                connection: .init(metadata: metadata, channel: member.channel),
                host: host)
        
        case .secondary(let metadata)?:
            self.secondaries.append(.init(
                connection: .init(metadata: metadata, channel: member.channel),
                host: host))
        
        case .arbiter?:
            self.undesirables.append(.init(reason: .arbiter, host: host))
        
        case .other?:
            self.undesirables.append(.init(reason: .other, host: host))
        
        case nil:
            self.undesirables.append(.init(reason: .ghost, host: host))
        }
    }
}
extension MongoTopology.Replicas
{
    var freshest:Freshest?
    {
        if let primary:MongoTopology.Server<MongoTopology.Replica> = self.primary
        {
            return .primary(primary.connection.metadata.timings)
        }
        else
        {
            return self.secondaries.max
            {
                $0.connection.metadata.timings.write.value <
                $1.connection.metadata.timings.write.value
            }
                .map
            {
                .secondary($0.connection.metadata.timings.write)
            }
        }
    }
}
extension MongoTopology.Replicas
{
    func undesirables(assuming candidacy:MongoTopology.Candidacy)
        -> [MongoTopology.Rejection<MongoTopology.Undesirable>]
    {
        switch candidacy
        {
        case .primaryRequired:
            return self.undesirables + self.secondaries.lazy.map
            {
                .init(reason: .secondary, host: $0.host)
            }
        
        case .primaryPreferred, .nearest, .secondaryPreferred:
            return self.undesirables
        
        case .secondaryRequired:
            return self.primary.map
            {
                self.undesirables + [.init(reason: .primary, host: $0.host)]
            }
            ??  self.undesirables
        }
    }
}
extension MongoTopology.Replicas
{
    func nearestPrimary() -> Result<MongoChannel, MongoTopology.SelectionError>
    {
        if let primary:MongoTopology.Server<MongoTopology.Replica> = self.primary
        {
            return .success(primary.connection.channel)
        }
        else
        {
            return .failure(.init(unreachable: self.unreachables,
                undesirable: self.undesirables(assuming: .primaryRequired)))
        }
    }
    func nearestPrimaryOrSecondary(matching filter:MongoTopology.Eligibility)
        -> Result<MongoChannel, MongoTopology.SelectionError>
    {
        if let primary:MongoTopology.Server<MongoTopology.Replica> = self.primary
        {
            return .success(primary.connection.channel)
        }
        switch filter.select(among: self.secondaries)
        {
        case .success(let channel):
            return .success(channel)
        
        case .failure(let servers):
            return .failure(.init(unreachable: self.unreachables,
                undesirable: self.undesirables(assuming: .primaryPreferred),
                unsuitable: servers.unsuitable))
        }
    }
    func nearest(matching filter:MongoTopology.Eligibility)
        -> Result<MongoChannel, MongoTopology.SelectionError>
    {
        switch filter.select(among: self.secondaries + (self.primary.map { [$0] } ?? []))
        {
        case .success(let channel):
            return .success(channel)
        
        case .failure(let servers):
            return .failure(.init(unreachable: self.unreachables,
                undesirable: self.undesirables(assuming: .nearest),
                unsuitable: servers.unsuitable))
        }
    }
    func nearestSecondaryOrPrimary(matching filter:MongoTopology.Eligibility)
        -> Result<MongoChannel, MongoTopology.SelectionError>
    {
        switch filter.select(among: self.secondaries, else: self.primary?.connection.channel)
        {
        case .success(let channel):
            return .success(channel)
        
        case .failure(let servers):
            return .failure(.init(unreachable: self.unreachables,
                undesirable: self.undesirables(assuming: .secondaryPreferred),
                unsuitable: servers.unsuitable))
        }
    }
    func nearestSecondary(matching filter:MongoTopology.Eligibility)
        -> Result<MongoChannel, MongoTopology.SelectionError>
    {
        switch filter.select(among: self.secondaries)
        {
        case .success(let channel):
            return .success(channel)
        
        case .failure(let servers):
            return .failure(.init(unreachable: self.unreachables,
                undesirable: self.undesirables(assuming: .secondaryRequired),
                unsuitable: servers.unsuitable))
        }
    }
}
