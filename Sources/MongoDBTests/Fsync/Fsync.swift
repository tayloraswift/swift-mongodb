import MongoDB
import MongoTesting

struct Fsync:MongoTestBattery
{
    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
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
