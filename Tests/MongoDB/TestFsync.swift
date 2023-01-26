import MongoDB
import Testing

func TestFsync(_ tests:TestGroup,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<Mongo.Host>) async
{
    let tests:TestGroup = tests / "fsync-locking"
    
    await tests.withTemporaryDatabase(named: "fsync-tests",
        bootstrap: bootstrap,
        hosts: hosts)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        // ensure we are locking and unlocking the same node!
        let node:Mongo.ReadPreference = .nearest(tagSets: [["name": "A"]])

        var lock:Mongo.FsyncLock
        
        lock = try await pool.run(command: Mongo.Fsync.init(lock: true),
            against: .admin,
            on: node)
        
        tests.expect(lock.count ==? 1)

        lock = try await pool.run(command: Mongo.FsyncUnlock.init(),
            against: .admin,
            on: node)

        tests.expect(lock.count ==? 0)
    }
}
