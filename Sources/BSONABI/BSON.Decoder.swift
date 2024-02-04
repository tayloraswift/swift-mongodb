extension BSON
{
    public
    typealias Decoder = _BSONDecoder
}

/// The name of this protocol is ``BSON.Decoder``.
public
protocol _BSONDecoder
{
    init(parsing bson:borrowing BSON.AnyValue) throws
}
