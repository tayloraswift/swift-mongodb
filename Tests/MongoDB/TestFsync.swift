import MongoDB
import Testing

func TestFsync(_ tests:inout Tests,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<Mongo.Host>) async
{
    await tests.withTemporaryDatabase(name: "fsync-locking",
        bootstrap: bootstrap,
        hosts: hosts)
    {
        (tests:inout Tests, pool:Mongo.SessionPool, database:Mongo.Database) in

        // ensure we are locking and unlocking the same node!
        let node:Mongo.ReadPreference = .nearest(tagSets: [["name": "A"]])

        var lock:Mongo.FsyncLock
        
        lock = try await pool.run(command: Mongo.Fsync.init(lock: true),
            against: .admin,
            on: node)
        
        tests.assert(lock.count ==? 1, name: "lock-count-locked")

        lock = try await pool.run(command: Mongo.FsyncUnlock.init(),
            against: .admin,
            on: node)

        tests.assert(lock.count ==? 0, name: "lock-count-unlocked")
    }
}
