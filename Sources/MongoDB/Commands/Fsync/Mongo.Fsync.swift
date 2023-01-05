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
extension Mongo.Fsync:MongoCommand
{
    public
    typealias Response = Mongo.FsyncLock

    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["fsync"] = 1 as Int32
        bson["lock"] = self.lock
    }
}
extension Mongo.Fsync:MongoImplicitSessionCommand
{
}
