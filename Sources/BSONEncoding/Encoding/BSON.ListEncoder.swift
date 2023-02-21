extension BSON
{
    @frozen public
    struct ListEncoder
    {
        public
        var output:BSON.Output<[UInt8]>
        public
        var count:Int

        @inlinable public
        init(output:BSON.Output<[UInt8]>)
        {
            self.output = output
            self.count = 0
        }
    }
}
extension BSON.ListEncoder:BSONEncoder
{
    @inlinable public static
    var type:BSON { .list }
}
extension BSON.ListEncoder
{
    @inlinable public mutating
    func append(with serialize:(inout BSON.Field) -> ())
    {
        self.output.with(key: .init(index: self.count), do: serialize)
        self.count += 1
    }
    @inlinable public mutating
    func append(_ value:some BSONStreamEncodable)
    {
        self.append(with: value.encode(to:))
    }
}
