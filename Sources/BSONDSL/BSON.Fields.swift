import BSON

extension BSON
{
    @frozen public
    struct Fields:Sendable
    {
        public
        var output:BSON.Output<[UInt8]>

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.output = .init(preallocated: bytes)
        }
    }
}
extension BSON.Fields
{
    @inlinable public mutating
    func append(key:String, with serialize:(inout BSON.Field) -> ())
    {
        self.output.with(key: key, do: serialize)
    }
    @inlinable public
    var bytes:[UInt8]
    {
        self.output.destination
    }
}
