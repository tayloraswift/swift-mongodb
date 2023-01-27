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
extension Mongo.Fsync:MongoImplicitSessionCommand, MongoCommand
{
    public
    typealias Database = Mongo.Database.Admin
    public
    typealias Response = Mongo.FsyncLock

    /// The string [`"fsync"`]().
    @inlinable public static
    var name:String
    {
        "fsync"
    }

    public
    func encode(to bson:inout BSON.Fields)
    {
        bson[Self.name] = 1 as Int32
        bson["lock"] = self.lock
    }
}
