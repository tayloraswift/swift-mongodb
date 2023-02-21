import BSON

extension BSON
{
    /// The `Document` type models the “universal” BSON DSL.
    ///
    /// It is expected that more-specialized BSON DSLs will wrap an
    /// instance of `Document`.
    @frozen public
    struct Document:Sendable
    {
        public
        var output:BSON.Output<[UInt8]>

        @inlinable public
        init()
        {
            self.output = .init(preallocated: [])
        }
        @inlinable public
        init(bytes:[UInt8])
        {
            self.output = .init(preallocated: bytes)
        }
    }
}
extension BSON.Document:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.output.destination
    }
}
extension BSON.Document
{
    @inlinable public mutating
    func append(contentsOf other:Self)
    {
        self.output.append(other.bytes)
    }
    @inlinable public mutating
    func append(_ key:String, with serialize:(inout BSON.Field) -> ())
    {
        self.output.with(key: .init(rawValue: key), do: serialize)
    }
}
//  When adding overloads to any ``Optional`` whose ``Wrapped`` value
//  conforms to ``BSONDSLEncodable``, mark them as `@_disfavoredOverload`
//  to prevent them from shadowing the ``subscript(pushing)`` interface.
// extension BSON.Document?
// {
//     @inlinable public
//     init(with populate:(inout Wrapped) throws -> ()) rethrows
//     {
//         self = .some(try .init(with: populate))
//     }
// }
