import MongoDB
import Testing

@Suite
struct Fsync
{
    @Test(arguments: [.single, .replicated] as [any Mongo.TestConfiguration])
    func fsync(_ configuration:any Mongo.TestConfiguration) async throws
    {
        let bootstrap:Mongo.DriverBootstrap = configuration.bootstrap(on: .singleton)
        try await bootstrap.withSessionPool(logger: .init(level: .error))
        {
            try await self.run(with: $0)
        }
    }

    func run(with pool:Mongo.SessionPool) async throws
    {
        //  We should ensure we are locking and unlocking the same node!
        let node:Mongo.ReadPreference = .nearest(tagSets: [["name": "A"]])

        var lock:Mongo.FsyncLock

        lock = try await pool.run(command: Mongo.Fsync.init(lock: true),
            against: .admin,
            on: node)

        #expect(lock.count == 1)

        //  We should always be able to run the ping command, even if the
        //  node is write-locked.
        try await pool.run(command: Mongo.Ping.init(), against: .admin, on: node)

        lock = try await pool.run(command: Mongo.FsyncUnlock.init(),
            against: .admin,
            on: node)

        #expect(lock.count == 0)
    }
}
