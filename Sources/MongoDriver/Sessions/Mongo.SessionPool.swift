import NIOCore

extension Mongo
{
    enum TransactionState
    {
        case started
        case aborted
        case committed
    }
}
extension Mongo
{
    struct Transaction
    {
        var number:Int64
        var state:TransactionState?

        init()
        {
            self.number = 1
            self.state = nil
        }
    }
}

extension Mongo
{
    @available(*, deprecated, renamed: "SessionPool")
    public
    typealias Cluster = SessionPool

    public 
    actor SessionPool
    {
        nonisolated
        let deployment:Deployment

        private
        var available:[SessionIdentifier: SessionMetadata]
        private
        var claimed:Set<SessionIdentifier>

        public
        init(credentials:Credentials? = nil,
            settings:ConnectionSettings,
            resolver:DNS.Connection? = nil,
            group:any EventLoopGroup,
            seeds:Set<Mongo.Host>) 
        {
            self.deployment = .init(credentials: credentials,
                settings: settings,
                resolver: resolver,
                group: group,
                seeds: seeds)
            self.available = [:]
            self.claimed = []
        }

        deinit
        {
            guard self.claimed.isEmpty
            else
            {
                fatalError("unreachable: draining session pool while sessions are still in use!")
            }
            
            let sessions:[SessionIdentifier] = .init(self.available.keys)
            let _:Task<Void, Never> = .init
            {
                [deployment] in

                do
                {
                    if !sessions.isEmpty,
                        case nil = try await deployment.end(sessions: sessions)
                    {
                        print("endSessions: no suitable server")
                    }
                }
                catch let error
                {
                    print("endSessions:", error)
                }
                await deployment.terminate()
                print("deinitialized session pool")
            }
        }
    }
}
extension Mongo.SessionPool
{
    private
    func checkout(medium:Mongo.SessionMedium) -> Mongo.SessionContext
    {
        let now:ContinuousClock.Instant = .now
        while case let (id, metadata)? = self.available.popFirst()
        {
            if now < metadata.touched.advanced(by: .minutes(medium.timeout - 1))
            {
                self.claimed.update(with: id)
                return .init(id: id, medium: medium, metadata: metadata)
            }
        }
        // very unlikely, but do not generate a session id that we have
        // already generated. this is not foolproof (because we could
        // have persistent sessions from a previous run), but allows us
        // to maintain local dictionary invariants.
        while true
        {
            let id:Mongo.SessionIdentifier = .random()
            if case nil = self.claimed.update(with: id)
            {
                return .init(id: id, medium: medium, metadata: .init(touched: now))
            }
        }
    }
    nonisolated
    func checkout(selector:Mongo.ServerSelector) async -> Mongo.SessionContext
    {
        await self.checkout(medium: await self.deployment.medium(selector: selector))
    }
    func checkin(session:Mongo.SessionContext)
    {
        guard case _? = self.claimed.remove(session.id)
        else
        {
            fatalError("unreachable: released an unknown session! (\(session.id))")
        }
        guard case nil = self.available.updateValue(session.metadata, forKey: session.id)
        else
        {
            fatalError("unreachable: released an duplicate session! (\(session.id))")
        }
    }
}
extension Mongo.SessionPool
{
    /// Runs a session command against the ``Mongo/Database/.admin`` database,
    /// sending the command to an appropriate cluster member for its type.
    public nonisolated
    func run<Command>(command:Command) async throws -> Command.Response
        where Command:MongoImplicitSessionCommand
    {    
        try await Mongo.MutableSession.init(on: self).run(command: command)
    }
    /// Runs a session command against the specified database,
    /// sending the command to an appropriate cluster member for its type.
    public nonisolated
    func run<Command>(command:Command, 
        against database:Mongo.Database) async throws -> Command.Response
        where Command:MongoImplicitSessionCommand & MongoDatabaseCommand
    {    
        try await Mongo.MutableSession.init(on: self).run(command: command, against: database)
    }
}
