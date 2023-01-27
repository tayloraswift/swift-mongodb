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

    /// The string [`"fsyncUnlock"`]().
    @inlinable public static
    var name:String
    {
        "fsyncUnlock"
    }
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson[Self.name] = 1 as Int32
    }
}
