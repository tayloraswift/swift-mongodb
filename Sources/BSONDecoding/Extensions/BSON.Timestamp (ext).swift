extension BSON.Timestamp:BSONDecodable
{
    /// Attempts to cast a BSON variant backed by some storage type to a
    /// MongoDB timestamp. The conversion is not a integer case, and will
    /// succeed if and only if the variant has type ``BSON.AnyType/timestamp``.
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        self = try bson.cast
        {
            if  case .timestamp(let value) = $0
            {
                value
            }
            else
            {
                nil
            }
        }
    }
}
