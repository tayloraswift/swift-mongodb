extension Optional:BSONDecodable where Wrapped:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        if case .null = bson
        {
            self = .none
        }
        else
        {
            self = .some(try .init(bson: bson))
        }
    }
}
