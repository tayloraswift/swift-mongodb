extension BSON
{
    @frozen public
    struct DocumentEncoder<CodingKey> where CodingKey:Hashable & RawRepresentable<String>
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
extension BSON.DocumentEncoder:BSONEncoder
{
    @inlinable public static
    var type:BSON { .document }
}
extension BSON.DocumentEncoder:BSONBuilder
{
    @inlinable public mutating
    func append(_ key:CodingKey, _ value:some BSONDSLEncodable)
    {
        self.output.with(key: .init(key), do: value.encode(to:))
    }
}
