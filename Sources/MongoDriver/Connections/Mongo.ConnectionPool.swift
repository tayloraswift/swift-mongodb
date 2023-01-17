import BSON
import Heartbeats
import MongoChannel
import MongoMonitoring
import MongoWire
import NIOCore

//  these are extensions on the ``MongoMonitoringDelegate`` so they
//  only appear as public API if you import that module explicitly.
extension MongoMonitoringDelegate where Self == Mongo.ConnectionPool
{
    public nonisolated
    func requestRecheck()
    {
        self.heart.beat()
    }
    public nonisolated
    func stopMonitoring()
    {
        self.heart.stop()
    }
    public nonisolated
    func stopMonitoring(throwing error:any Error)
    {
        self.heart.stop(throwing: error)
    }
}
extension Mongo.ConnectionPool:MongoMonitoringDelegate
{
}

extension Mongo
{
    public
    actor ConnectionPool
    {
        /// The generation number of this connection pool. The pool attaches this
        /// token to every connection created from it.
        nonisolated
        let generation:UInt
        /// The connection timeout used internally by the pool to create connections.
        /// The service monitor also uses this to compute deadlines for server
        /// monitoring operations.
        nonisolated
        let timeout:ConnectionTimeout
        /// The heartbeat controller for the monitoring task that created this pool.
        nonisolated
        let heart:Heart
        /// The maximum number of connections this pool can establish concurrently.
        nonisolated
        let width:Int
        /// The target size of this connection pool. The pool will attempt to grow
        /// until it contains at least the minimum number of connections, and it will
        /// never exceed the maximum connection count.
        nonisolated
        let size:ClosedRange<Int>
        /// The host this pool creates connections to.
        nonisolated
        let host:Host


        private
        var requests:[UInt: CheckedContinuation<MongoChannel?, Never>]
        private
        var counter:UInt
        
        private
        var retained:Set<MongoChannel>
        private
        var released:[MongoChannel]
        private
        var pending:Int

        private
        var state:State

        init(generation:UInt, signaling heart:Heart,
            bootstrap:Bootstrap,
            host:Mongo.Host)
        {
            self.generation = generation
            self.timeout = bootstrap.timeout
            self.heart = heart
            self.width = 2
            self.size = 0 ... 100
            self.host = host

            self.requests = [:]
            self.counter = 0

            self.retained = []
            self.released = []
            self.pending = 0

            self.state = .filling(.init(channel: bootstrap.bootstrap(for: host),
                _credentials: bootstrap.credentials,
                _appname: bootstrap.appname,
                host: host))

            let _:Task<Void, Never> = .init
            {
                await self.resize()
            }
        }
        deinit
        {
            guard case .draining(nil) = self.state
            else
            {
                fatalError("unreachable (deinitialized connection pool that has not been drained!)")
            }
            guard self.requests.isEmpty
            else
            {
                fatalError("unreachable (deinitialized connection pool while continuations are awaiting!)")
            }
            guard self.released.isEmpty
            else
            {
                fatalError("unreachable (deinitialized connection pool without clearing destroyed channels!)")
            }
            guard self.retained.isEmpty
            else
            {
                fatalError("unreachable (deinitialized connection pool without waiting for all channels to be destroyed!)")
            }
            guard self.pending == 0
            else
            {
                fatalError("unreachable (deinitialized connection pool while connections are still being established!)")
            }
        }
    }
}
extension Mongo.ConnectionPool
{
    var isEmpty:Bool
    {
        self.released.isEmpty &&
        self.retained.isEmpty &&
        self.pending == 0
    }
    var count:Int
    {
        self.pending + self.released.count + self.retained.count
    }
}
extension Mongo.ConnectionPool
{
    private
    func next() -> MongoChannel?
    {
        guard let channel:MongoChannel = self.released.popLast()
        else
        {
            return nil
        }
        if case nil = self.retained.update(with: channel)
        {
            return channel
        }
        else
        {
            fatalError("unreachable (retained a channel more than once!)")
        }
    }
    private
    func request() -> UInt
    {
        self.counter += 1
        return self.counter
    }
    private
    func submit(_ request:UInt, continuation:CheckedContinuation<MongoChannel?, Never>)
    {
        self.requests.updateValue(continuation, forKey: request)
    }
    private
    func fail(_ request:UInt, by deadline:Mongo.ConnectionDeadline) async throws
    {
        //  will throw ``CancellationError`` if request succeeds
        try await Task.sleep(until: deadline.instant, clock: .continuous)
        if  let continuation:CheckedContinuation<MongoChannel?, Never> =
                self.requests.removeValue(forKey: request)
        {
            continuation.resume(returning: nil)
        }
    }
}
extension Mongo.ConnectionPool
{    
    func drain() async
    {
        if case .draining(_?) = self.state
        {
            fatalError("unreachable (draining connection pool that is already being drained!)")
        }

        for request:CheckedContinuation<MongoChannel?, Never> in self.requests.values
        {
            request.resume(returning: nil)
        }
        self.requests = [:]

        if  self.isEmpty
        {
            self.state = .draining(nil)
            return
        }

        let released:[MongoChannel] = self.released
        self.released = []

        async
        let direct:Void = withTaskGroup(of: Void.self)
        {
            (tasks:inout TaskGroup<Void>) in

            for channel:MongoChannel in released
            {
                tasks.addTask
                {
                    await channel.close()
                }
            }
        }
        
        //  need to check this again since we got rid of the released channels
        if  self.isEmpty
        {
            self.state = .draining(nil)
            await direct
            return
        }

        await withCheckedContinuation
        {
            self.state = .draining($0)

            for channel:MongoChannel in self.retained
            {
                channel.interrupt()
            }
        }
        await direct
    }
}

extension Mongo.ConnectionPool
{
    public nonisolated
    func destroy(_ connection:Mongo.Connection)
    {
        guard self.generation == connection.generation
        else
        {
            fatalError("unreachable (destroying connection that was created by a different pool)")
        }
        let _:Task<Void, Never> = .init
        {
            await self.checkin(channel: connection.channel)
        }
    }
    public nonisolated
    func create(by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.Connection
    {
        if let channel:MongoChannel = await self.checkout(by: deadline)
        {
            return .init(generation: self.generation, channel: channel)
        }
        else
        {
            throw Mongo.ConnectionCheckoutError.init()
        }
    }
}
extension Mongo.ConnectionPool
{
    private
    func checkout(by deadline:Mongo.ConnectionDeadline) async -> MongoChannel?
    {
        while case .filling(let bootstrap) = self.state
        {
            if  let channel:MongoChannel = self.next()
            {
                return channel
            }
            guard   self.pending < self.width,
                    self.count < self.size.upperBound
            else
            {
                let request:UInt = self.request()

                async
                let _:Void = self.fail(request, by: deadline)

                return await withCheckedContinuation
                {
                    self.submit(request, continuation: $0)
                }
            }

            await self.grow(using: bootstrap)
        }

        return nil
    }
    private
    func checkin(channel:MongoChannel) async
    {
        switch self.state
        {
        case .filling:
            if  let continuation:CheckedContinuation<MongoChannel?, Never> =
                self.requests.popFirst()?.value
            {
                continuation.resume(returning: channel)
            }
            else if case _? = self.retained.remove(channel)
            {
                self.released.append(channel)
            }
            else
            {
                fatalError("unreachable (released a channel more than once!)")
            }
            return
        
        case .draining:
            await channel.close()
            //  we have to wait for the channel to close before removing
            //  it from the retained list, because a re-entrant call to this
            //  method might observe `self.count == 0` while the channel is
            //  still open.
            guard case _? = self.retained.remove(channel)
            else
            {
                fatalError("unreachable (released a channel more than once!)")
            }
        }

        if  self.isEmpty,
            case .draining(let continuation?) = self.state
        {
            continuation.resume()
            self.state = .draining(nil)
        }
    }
    private
    func resize() async
    {
        if  case .filling(let bootstrap) = self.state,
            self.pending < self.width,
            self.count < self.size.lowerBound
        {
            await self.grow(using: bootstrap)
        }
    }
    private
    func grow(using bootstrap:Mongo.Connection.Bootstrap) async
    {
        do
        {
            self.pending += 1

            let deadline:Mongo.ConnectionDeadline = self.timeout.deadline(from: .now)
            let channel:MongoChannel = try await bootstrap.channel(to: self.host, by: deadline)

            switch self.state
            {
            case .filling:
                self.released.append(channel)
                self.pending -= 1

                if  self.pending < self.width,
                    self.count < self.size.lowerBound
                {
                    let _:Task<Void, Never> = .init
                    {
                        //  re-checks preconditions, since it may have been a while
                        //  since this task was initiated.
                        await self.resize()
                    }
                }

                return
            
            case .draining:
                await channel.close()
                self.pending -= 1
            }

            if  self.isEmpty,
                case .draining(let continuation?) = self.state
            {
                continuation.resume()
                self.state = .draining(nil)
            }
        }
        catch let error
        {
            self.pending -= 1

            switch self.state
            {
            case .filling:
                self.stopMonitoring(throwing: error)
                self.state = .draining(nil)
            
            case .draining(nil):
                break
            
            case .draining(let continuation?):
                if  self.isEmpty
                {
                    continuation.resume()
                    self.state = .draining(nil)
                }
            }
        }
    }
}
// extension Mongo.ConnectionPool
// {
//     /// Attempts to obtain a connection by the given deadline, encodes the given
//     /// labeled command to a document, sends it over the connection and awaits
//     /// its reply.
//     @inlinable public
//     func run<Command>(command:__owned Mongo.LabeledCommand<Command>,
//         against database:Command.Database,
//         by deadline:ContinuousClock.Instant) async throws -> Mongo.Reply
//         where Command:MongoCommand
//     {
//         let connection:Mongo.Connection = try await self.create(by: deadline)
//         defer
//         {
//             self.destroy(connection)
//         }
//         return try await connection.run(command: command, against: database)
//     }
// }

