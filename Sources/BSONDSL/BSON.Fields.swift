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
//  When adding overloads to any ``Optional`` whose ``Wrapped`` value
//  conforms to ``BSONDSLEncodable``, mark them as `@_disfavoredOverload`
//  to prevent them from shadowing the ``subscript(pushing)`` interface.
extension BSON.Fields?
{
    @inlinable public
    init(with populate:(inout Wrapped) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
}
