import MongoABI

extension Mongo.Database
{
    @frozen public
    enum Admin:Hashable, Sendable
    {
        case admin
    }
}
extension Mongo.Database.Admin:Mongo.DatabaseType
{
    @inlinable public
    var name:String { "admin" }
}
