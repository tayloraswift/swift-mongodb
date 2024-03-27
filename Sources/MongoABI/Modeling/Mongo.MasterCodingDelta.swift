import BSON

extension Mongo
{
    /// A master coding delta type is like a ``MasterCodingModel``, but it has slightly
    /// different implied constraints, because you generally only ever decode a delta you
    /// receive from elsewhere.
    public
    protocol MasterCodingDelta<CodingKey>:BSONDecodable
    {
        associatedtype CodingKey:BSONDecodable
    }
}
