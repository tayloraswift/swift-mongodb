extension BSON
{
    @frozen public
    struct DocumentEncoder<CodingKey> where CodingKey:RawRepresentable<String>
    {
        @usableFromInline internal
        var output:BSON.Output<[UInt8]>

        @inlinable public
        init(_ output:BSON.Output<[UInt8]>)
        {
            self.output = output
        }
    }
}
extension BSON.DocumentEncoder:BSON.Encoder
{
    @inlinable public consuming
    func move() -> BSON.Output<[UInt8]> { self.output }

    @inlinable public static
    var type:BSON.AnyType { .document }
}
extension BSON.DocumentEncoder:_BSONBuilder
{
    @inlinable public mutating
    func append(_ key:CodingKey, with encode:(inout BSON.Field) -> ())
    {
        encode(&self.output[with: .init(key)])
    }
}
