extension BSON
{
    public
    typealias Decoder = _BSONDecoder
}

/// The name of this protocol is ``BSON.Decoder``.
public
protocol _BSONDecoder<Storage>
{
    associatedtype Storage:RandomAccessCollection<UInt8>

    init(parsing bson:borrowing BSON.AnyValue<Storage>) throws
}

extension BSON.Decoder
{
    /// Decoder elements are indices over fragments of BSON parsed from a larger allocation,
    /// like ``Substring``s from a larger parent ``String``.
    public
    typealias Bytes = Storage.SubSequence
}
