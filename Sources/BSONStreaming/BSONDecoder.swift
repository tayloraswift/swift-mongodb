import BSONTypes

public
protocol BSONDecoder<Storage>
{
    associatedtype Storage:RandomAccessCollection<UInt8>

    init(parsing bson:__shared BSON.AnyValue<Storage>) throws
}
extension BSONDecoder
{
    /// Ddecoder elements are indices over fragments of BSON
    /// parsed from a larger allocation, like ``Substring``s from a
    /// larger parent ``String``.
    public
    typealias Bytes = Storage.SubSequence
}
