import UnixTime

extension UnixMillisecond:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        self = try bson.cast { $0.as(Self.self) }
    }
}
