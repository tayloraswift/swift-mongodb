import Durations
import MongoChannel
import MongoTopology

extension Mongo
{
    public
    struct ConnectionTimeoutError:Error
    {
        public
        let preference:ReadPreference

        public
        init(preference:ReadPreference)
        {
            self.preference = preference
        }
    }
}
extension Mongo.ConnectionTimeoutError:CustomStringConvertible
{
    public
    var description:String
    {
        "timed out waiting for a server matching read preference '\(self.preference)' to join topology"
    }
}

extension Mongo
{
    struct ConnectionRequest
    {
        let preference:ReadPreference
        let promise:CheckedContinuation<MongoChannel, any Error>

        init(preference:ReadPreference,
            promise:CheckedContinuation<MongoChannel, any Error>)
        {
            self.preference = preference
            self.promise = promise
        }
    }
}
extension Mongo.ConnectionRequest?
{
    mutating
    func fail()
    {
        if let request:Mongo.ConnectionRequest = self
        {
            request.promise.resume(throwing: Mongo.ConnectionTimeoutError.init(
                preference: request.preference))
            self = nil
        }
    }
    mutating
    func fulfill(with channel:MongoChannel,
        where predicate:(Mongo.ReadPreference) -> Bool)
    {
        if let request:Mongo.ConnectionRequest = self, predicate(request.preference)
        {
            request.promise.resume(returning: channel)
            self = nil
        }
    }
}






// extension Mongo.ConnectionPool
// {
//     struct Sharded:Sendable
//     {
//         var routers:[Server<MongoTopology.Router>]
//     }
// }
// extension Mongo.ConnectionPool
// {
//     struct Single:Sendable
//     {
//         var standalone:Server<MongoTopology.Standalone>?
//     }
// }

extension Mongo
{
    public final
    actor ConnectionPool
    {
        private
        var servers:MongoTopology.Servers

        private
        var requests:[UInt: ConnectionRequest]
        private
        var counter:UInt

        private nonisolated
        let clock:ContinuousClock

        init()
        {
            self.servers = .unknown([])

            self.requests = [:]
            self.counter = 0

            self.clock = .init()
        }
    }
}
extension Mongo.ConnectionPool
{
    subscript(preference:Mongo.ReadPreference) -> Result<MongoChannel, Mongo.SelectionError>
    {
        switch self.servers
        {
        case .unknown(let undesirables):
            return .failure(.init(undesirable: undesirables.map
            {
                .init(reason: .ghost, host: $0.host)
            }))
        
        case .single(let standalone):
            switch preference
            {
            case    .secondary:
                return .failure(.init(undesirable:
                [
                    .init(reason: .standalone, host: standalone.host),
                ]))
            case    .secondaryPreferred,
                    .nearest,
                    .primaryPreferred,
                    .primary:
                break
            }
            switch standalone.state
            {
            case .connected(let channel, metadata: _):
                return .success(channel)
            
            case .errored(let error):
                return .failure(.init(unusable:
                [
                    .init(reason: .errored(error), host: standalone.host),
                ]))
            
            case .queued:
                return .failure(.init(unusable:
                [
                    .init(reason: .queued, host: standalone.host),
                ]))
            }
        
        case .sharded(let routers):
            routers[]
        
        case .replicated(let replicas):
            var rejected:Mongo.SelectionError
            {
                .init(undesirable: replicas.undesirables.map { .init(reason: .ghost, host: $0.host) })
            }
            switch preference
            {
            case .secondary          (maxStaleness: let maxStaleness, tagSets: let tagSets, hedge: _):
                break
            case .secondaryPreferred (maxStaleness: let maxStaleness, tagSets: let tagSets, hedge: _):
                break
            case .nearest            (maxStaleness: let maxStaleness, tagSets: let tagSets, hedge: _):
                break
            case .primaryPreferred   (maxStaleness: let maxStaleness, tagSets: let tagSets, hedge: _):
                break
                else
                {
                    return .failure(.init(
                        undesirable: replicas.undesirables,
                        ineligible: ineligible,
                        unsuitable: unsuitable))
                }
            case .primary:
                guard   let primary:MongoTopology.Server<MongoTopology.Replica.Master> =
                            replicas.primary
                else
                {
                    return .failure(.init(
                        undesirable: replicas.secondaries + replicas.undesirables))
                }
                return .success(primary.channel)
                {
                }
            }
        }
    }
}
extension Mongo.ConnectionPool
{
    var isEmpty:Bool
    {
        self.requests.isEmpty
    }

    private
    func request() -> UInt
    {
        self.counter += 1
        return self.counter
    }
    private
    func submit(_ id:UInt, request:Mongo.ConnectionRequest)
    {
        
    }
    private
    func fulfill(with channel:MongoChannel,
        where predicate:(Mongo.ReadPreference) -> Bool)
    {
        for key:UInt in self.requests.keys
        {
            self.requests[key].fulfill(with: channel, where: predicate)
        }
    }
}
extension Mongo.ConnectionPool
{
    @usableFromInline
    func channel(to preference:Mongo.ReadPreference,
        timeout:Duration) async throws -> MongoChannel
    {
        if  let channel:MongoChannel = self.topology[preference]
        {
            return channel
        }
        else
        {
            let started:ContinuousClock.Instant = self.clock.now
            let request:UInt = self.request()

            #if compiler(>=5.8)
            async
            let _:Void = self.fail(request: request, once: started.advanced(by: timeout))
            #else
            async
            let __:Void = self.fail(request: request, once: started.advanced(by: timeout))
            #endif

            return try await withCheckedThrowingContinuation
            {
                self.requests.updateValue(.init(preference: preference, promise: $0),
                    forKey: request)
            }
        }
    }
    private
    func fail(request:UInt, once instant:ContinuousClock.Instant) async throws
    {
        //  will throw ``CancellationError`` if request succeeds
        try await Task.sleep(until: instant, clock: self.clock)
        self.requests[request].fail()
    }
}
