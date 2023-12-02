import BSON

/// A `MongoListDSL` is nothing more than a type that supports an
/// ``init(with:)`` builder API.
///
/// The specific encoding API vended and encodability protocol used is up to
/// the conforming type.
public
protocol MongoListDSL:BSONRepresentable<BSON.List>, BSONDecodable, BSONEncodable
{
    associatedtype Encoder:BSON.Encoder
}
extension MongoListDSL
{
    @inlinable public
    init()
    {
        self.init(.init())
    }
    /// Creates an empty instance of this type, and initializes it with the
    /// given closure.
    @inlinable public
    init(with populate:(inout Encoder) throws -> ()) rethrows
    {
        var list:BSON.List = .init()
        try populate(&list.output[as: Encoder.self])
        self.init(list)
    }
}
extension MongoListDSL
    where Self:ExpressibleByArrayLiteral, ArrayLiteralElement == Never
{
    @inlinable public
    init(arrayLiteral:Never...)
    {
        //  Weirdly, if we try to call `Self.init`, this will call itself instead...
        self.init(.init())
    }
}
