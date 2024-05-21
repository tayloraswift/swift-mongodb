/// A type that can be encoded to a BSON binary array. Not to be confused with
/// ``BSONListEncodable``.
public
protocol BSONArrayEncodable<CodingElement>:BSONBinaryEncodable
{
    associatedtype CodingElement //:_Trivial
}
extension BSONArrayEncodable where Self:RandomAccessCollection<CodingElement>
{
    /// Encodes the elements of this collection to the binary encoder by densely copying each
    /// element’s raw memory representation, without any padding.
    @inlinable public
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        bson.reserve(another: count * MemoryLayout<CodingElement>.size)

        for trivial:CodingElement in self
        {
            withUnsafeBytes(of: trivial) { bson += $0 }
        }
    }
}
