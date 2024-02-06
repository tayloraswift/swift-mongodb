import BSON

extension Mongo
{
    @frozen public
    struct Variable<T>:Equatable, Hashable, Sendable
    {
        public
        let name:BSON.Key

        @inlinable public
        init(name:BSON.Key)
        {
            self.name = name
        }
    }
}
extension Mongo.Variable where T:MongoMasterCodingModel
{
    @inlinable public
    subscript(key:T.CodingKey) -> Mongo.AnyKeyPath
    {
        //  When the key path is encoded, ``Mongo.AnyKeyPath``
        //  will add an additional prefixed dollar sign.
        .init(rawValue: "$\(self.name).\(key.rawValue)")
    }
}
extension Mongo.Variable:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(name: .init(rawValue: stringLiteral))
    }
}
extension Mongo.Variable:CustomStringConvertible
{
    /// Returns this variable’s ``name`` prefixed with two dollar signs.
    @inlinable public
    var description:String { "$$\(self.name)" }
}
extension Mongo.Variable:BSONStringEncodable
{
}
