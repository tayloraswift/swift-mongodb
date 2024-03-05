import BSON

extension Mongo
{
    @frozen public
    struct IndexBinding:Equatable, Hashable, Sendable
    {
        public
        let version:Int
        public
        let name:String

        @inlinable public
        init(version:Int, name:String)
        {
            self.version = version
            self.name = name
        }
    }
}
extension Mongo.IndexBinding
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case version = "v"
        case name
    }
}
extension Mongo.IndexBinding:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(version: try bson[.version].decode(), name: try bson[.name].decode())
    }
}
