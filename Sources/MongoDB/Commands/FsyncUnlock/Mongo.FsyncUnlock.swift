import BSONEncoding

extension Mongo
{
    public
    struct FsyncUnlock:Sendable
    {
        public
        init()
        {
        }
    }
}
extension Mongo.FsyncUnlock:MongoCommand
{
    public
    typealias Response = Mongo.FsyncLock

    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["fsyncUnlock"] = 1 as Int32
    }
}
extension Mongo.FsyncUnlock:MongoImplicitSessionCommand
{
}
