import MongoDB
import Testing

func TestFsync(_ tests:inout Tests,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<Mongo.Host>) async
{
    await tests.test(with: DatabaseEnvironment.init(bootstrap: bootstrap,
        database: "fsync-locking",
        hosts: hosts))
    {
        (tests:inout Tests, context:DatabaseEnvironment.Context) in

        // ensure we are locking and unlocking the same node!
        let node:Mongo.ReadPreference = .nearest(tagSets: [["name": "A"]])

        var lock:Mongo.FsyncLock
        
        lock = try await context.pool.run(command: Mongo.Fsync.init(lock: true),
            against: .admin,
            on: node)
        
        tests.assert(lock.count ==? 1, name: "lock-count-locked")

        lock = try await context.pool.run(command: Mongo.FsyncUnlock.init(),
            against: .admin,
            on: node)

        tests.assert(lock.count ==? 0, name: "lock-count-unlocked")
    }
}
