extension Mongo
{
    public
    struct UnsafeRunner
    {
        public
        let selection:Selection
        public
        let session:Session

        @inlinable public
        init(selection:Selection, session:Session)
        {
            self.selection = selection
            self.session = session
        }
    }
}
extension Mongo.UnsafeRunner
{
    @inlinable public
    func run<Command>(command:Command, against database:Mongo.Database,
        clusterTime:Mongo.ClusterTime) async throws -> Command.Response
        where Command:MongoSessionCommand
    {
        let labeled:Mongo.Labeled<Command> = .init(clusterTime: clusterTime,
            readPreference: self.selection.preference,
            readConcern: (command as? any MongoReadCommand).map
            {
                .init(level: $0.readLevel, after: self.session.state.lastOperationTime)
            },
            transaction: self.session.state.metadata.transaction,
            session: self.session.id,
            command: command)
        
        let sent:ContinuousClock.Instant = .now
        let reply:Mongo.Reply = try await self.selection.channel.run(labeled: labeled,
            against: database)

        self.session.state.update(touched: sent, operationTime: reply.operationTime)
        self.session.cluster.push(time: reply.clusterTime)

        return try Command.decode(reply: try reply.result.get())
    }

    @inlinable public
    func run<Command>(command:Command,
        against database:Mongo.Database) async throws -> Command.Response
        where Command:MongoSessionCommand
    {
        try await self.run(command: command, against: database,
            clusterTime: await self.session.cluster.time)
    }
}
