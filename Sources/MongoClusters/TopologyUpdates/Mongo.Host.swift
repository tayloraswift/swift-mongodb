import BSON

extension Mongo
{
    @frozen public
    struct Host:Hashable, Sendable
    {
        /// The hostname, such as [`"localhost"`](), [`"example.com"`](),
        /// or [`"127.0.0.1"`]().
        public
        var name:String

        /// The port. The default MongoDB port is 27017.
        public
        var port:Int

        @inlinable public
        init(name:String, port:Int? = nil)
        {
            self.name = name
            self.port = port ?? 27017
        }
    }
}
extension Mongo.Host:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.name, lhs.port) < (rhs.name, rhs.port)
    }
}
extension Mongo.Host
{
    // @inlinable public static
    // func srv(_ name:String) -> Self
    // {
    //     .init(name, 27017)
    // }
}
extension Mongo.Host:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String) { self.init(stringLiteral) }
}
extension Mongo.Host:LosslessStringConvertible
{
    @inlinable public
    init(_ string:some StringProtocol)
    {
        let port:Int?
        let name:String
        if  let colon:String.Index = string.firstIndex(of: ":")
        {
            name = .init(string.prefix(upTo: colon))
            port = .init(string.suffix(from: string.index(after: colon)))
        }
        else
        {
            name = .init(string)
            port = nil
        }
        self.init(name: name, port: port)
    }
}
extension Mongo.Host:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "\(self.name):\(self.port)"
    }
}
extension Mongo.Host:BSONDecodable, BSONStringDecodable
{
}
extension Mongo.Host:BSONEncodable, BSONStringEncodable
{
}
