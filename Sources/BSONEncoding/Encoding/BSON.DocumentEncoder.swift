extension BSON
{
    @frozen public
    struct DocumentEncoder<CodingKey> where CodingKey:RawRepresentable<String> & Hashable
    {
        public
        var output:BSON.Output<[UInt8]>

        @inlinable public
        init(output:BSON.Output<[UInt8]>)
        {
            self.output = output
        }
    }
}
extension BSON.DocumentEncoder:BSONBuilder
{
    @inlinable public mutating
    func append(_ key:CodingKey, with encode:(inout BSON.Field) -> ())
    {
        self.output.with(key: .init(key), do: encode)
    }
}
extension BSON.DocumentEncoder:BSONEncoder
{
    @inlinable public static
    var type:BSON { .document }
}
