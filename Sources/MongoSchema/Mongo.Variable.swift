import BSONEncoding

extension Mongo
{
    @frozen public
    struct Variable<T>:Equatable, Hashable, Sendable
    {
        public
        let name:String

        @inlinable public
        init(name:String)
        {
            self.name = name
        }
    }
}
extension Mongo.Variable where T:MongoMasterCodingModel
{
    @inlinable public
    subscript(key:T.CodingKey) -> Mongo.KeyPath
    {
        //  When the key path is encoded, ``Mongo.KeyPath``
        //  will add an additional prefixed dollar sign.
        .init("$\(self.name).\(key)")
    }
}
extension Mongo.Variable:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(name: stringLiteral)
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
