import MongoSchema

extension Mongo.Database
{
    @frozen public
    enum Admin:Hashable, Sendable
    {
        case admin
    }
}
extension Mongo.Database.Admin:MongoCommandDatabase
{
    @inlinable public
    var name:String
    {
        "admin"
    }
}
