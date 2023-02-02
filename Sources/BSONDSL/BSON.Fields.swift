import BSON

extension BSON
{
    /// The `Fields` type models the “universal” BSON DSL.
    ///
    /// It is expected that more-specialized BSON DSLs will wrap an
    /// instance of `Fields`.
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
extension BSON.Fields:BSONDSL
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
