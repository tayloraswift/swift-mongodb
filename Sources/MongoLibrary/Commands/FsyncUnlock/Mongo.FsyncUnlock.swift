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
    /// The string [`"fsyncUnlock"`]().
    @inlinable public static
    var name:String
    {
        "fsyncUnlock"
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
        }
    }
}
