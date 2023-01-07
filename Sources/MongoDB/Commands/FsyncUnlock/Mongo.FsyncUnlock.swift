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
extension Mongo.FsyncUnlock:MongoImplicitSessionCommand, MongoCommand
{
    public
    typealias Database = Mongo.Database.Admin
    public
    typealias Response = Mongo.FsyncLock

    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["fsyncUnlock"] = 1 as Int32
    }
}
