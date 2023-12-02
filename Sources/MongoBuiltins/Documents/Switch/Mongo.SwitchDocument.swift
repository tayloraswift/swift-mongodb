import BSON

extension Mongo
{
    @frozen public
    struct SwitchDocument:MongoDocumentDSL, Sendable
    {
        public
        var bson:BSON.Document

        @inlinable public
        init(_ bson:BSON.Document)
        {
            self.bson = bson
        }
    }
}
extension Mongo.SwitchDocument
{
    @inlinable public
    subscript(key:Branches) -> Mongo.SwitchBranches?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(key, value)
        }
    }

    @inlinable public
    subscript<Encodable>(key:Default) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(key, value)
        }
    }
}
