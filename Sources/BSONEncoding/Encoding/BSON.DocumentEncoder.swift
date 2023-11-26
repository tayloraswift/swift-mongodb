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
extension BSON.DocumentEncoder:BSONEncoder
{
    @inlinable public consuming
    func move() -> BSON.Output<[UInt8]> { self.output }

    @inlinable public static
    var type:BSON { .document }
}
extension BSON.DocumentEncoder:BSONBuilder
{
    @inlinable public mutating
    func append(_ key:CodingKey, with encode:(inout BSON.Field) -> ())
    {
        encode(&self.output[with: .init(key)])
    }
}
