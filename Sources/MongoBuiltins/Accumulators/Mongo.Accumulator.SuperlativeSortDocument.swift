import BSON

extension Mongo.Accumulator
{
    @frozen public
    struct SuperlativeSortDocument<Count>:MongoDocumentDSL, Sendable
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
extension Mongo.Accumulator.SuperlativeSortDocument
{
    @inlinable public
    subscript(key:Mongo.SortDocument.By) -> Mongo.SortDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
    @inlinable public
    subscript<Encodable>(key:Mongo.SortDocument.Output) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
extension Mongo.Accumulator.SuperlativeSortDocument<Mongo.SortDocument.Count>
{
    @inlinable public
    subscript<Encodable>(key:Mongo.SortDocument.Count) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
