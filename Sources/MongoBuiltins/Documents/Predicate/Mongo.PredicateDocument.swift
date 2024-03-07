import BSON

extension Mongo
{
    /// Not to be confused with ``FilterDocument``.
    ///
    /// You can use an empty dictionary literal (`[:]`) to express an
    /// unconditional predicate.
    @frozen public
    struct PredicateDocument:Sendable
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
extension Mongo.PredicateDocument:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.PredicateEncoder
}
extension Mongo.PredicateDocument:ExpressibleByDictionaryLiteral
{
}
