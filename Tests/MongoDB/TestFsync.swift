import MongoDB
import Testing

func TestFsync(_ tests:TestGroup,
    bootstrap:Mongo.DriverBootstrap,
    hosts:Set<Mongo.Host>) async
{
    guard let tests:TestGroup = tests / "fsync-locking"
    else
    {
        return
    }
    
    await tests.withTemporaryDatabase(named: "fsync-tests",
        bootstrap: bootstrap,
        hosts: hosts)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        //  We should ensure we are locking and unlocking the same node!
        let node:Mongo.ReadPreference = .nearest(tagSets: [["name": "A"]])

        var lock:Mongo.FsyncLock
        
        lock = try await pool.run(command: Mongo.Fsync.init(lock: true),
            against: .admin,
            on: node)
        
        tests.expect(lock.count ==? 1)

        //  We should always be able to run the ping command, even if the
        //  node is write-locked.
        await (tests ! "ping").do
        {
            try await pool.run(command: Mongo.Ping.init(),
                against: .admin,
                on: node)
        }

        lock = try await pool.run(command: Mongo.FsyncUnlock.init(),
            against: .admin,
            on: node)

        tests.expect(lock.count ==? 0)
    }
}
