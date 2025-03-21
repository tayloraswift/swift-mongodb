import BSON

extension Mongo
{
    public
    struct Fsync:Sendable
    {
        public
        let lock:Bool

        public
        init(lock:Bool)
        {
            self.lock = lock
        }
    }
}
extension Mongo.Fsync:Mongo.Command
{
    @inlinable public static
    var type:Mongo.CommandType { .fsync }

    public
    typealias Database = Mongo.Database.Admin
    public
    typealias Response = Mongo.FsyncLock

    public
    var fields:BSON.Document
    {
        Self.type(nil)
        {
            $0["lock"] = self.lock
        }
    }
}
