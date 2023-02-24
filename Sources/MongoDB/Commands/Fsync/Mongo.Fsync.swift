import BSONEncoding

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
extension Mongo.Fsync:MongoImplicitSessionCommand, MongoSessionCommand
{
    /// The string [`"fsync"`]().
    @inlinable public static
    var name:String
    {
        "fsync"
    }

    public
    typealias Database = Mongo.Database.Admin
    public
    typealias Response = Mongo.FsyncLock

    public
    var fields:BSON.Document
    {
        .init
        {
            $0[Self.name] = 1 as Int32
            $0["lock"] = self.lock
        }
    }
}
