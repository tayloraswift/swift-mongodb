import BSON

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
extension Mongo.FsyncUnlock:Mongo.Command
{
    @inlinable public static
    var type:Mongo.CommandType { .fsyncUnlock }

    public
    typealias Database = Mongo.Database.Admin
    public
    typealias Response = Mongo.FsyncLock

    public
    var fields:BSON.Document
    {
        Self.type(nil)
    }
}
