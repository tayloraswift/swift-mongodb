import BSON

extension Mongo
{
    @frozen public
    struct Database:Hashable, Sendable
    {
        public
        let name:String

        @inlinable public
        init(_ name:String)
        {
            self.name = name
        }
    }
}
extension Mongo.Database
{
    @inlinable public static
    func | <Name>(database:Self, name:Name) -> Mongo.Namespaced<Name>
    {
        .init(database, name)
    }
}
extension Mongo.Database:ExpressibleByStringLiteral
{
    public static
    let admin:Self = "admin"

    @inlinable public
    init(stringLiteral:String)
    {
        self.init(stringLiteral)
    }
}
extension Mongo.Database:LosslessStringConvertible
{
    @inlinable public
    var description:String
    {
        self.name
    }
}
extension Mongo.Database:BSONDecodable, BSONStringDecodable
{
}
extension Mongo.Database:BSONEncodable, BSONStringEncodable
{
}
