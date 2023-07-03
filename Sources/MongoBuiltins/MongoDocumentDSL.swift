import BSONDecoding
import BSONEncoding

/// A `MongoDocumentDSL` is nothing more than a type that supports an
/// ``init(with:)`` builder API.
///
/// The specific encoding API vended and encodability protocol used is up to
/// the conforming type.
public
protocol MongoDocumentDSL:BSONRepresentable<BSON.Document>, BSONDecodable, BSONEncodable
{
}
extension MongoDocumentDSL
{
    @inlinable public
    init()
    {
        self.init(.init())
    }
    /// Creates an empty instance of this type, and initializes it with the
    /// given closure.
    @inlinable public
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init()
        try populate(&self)
    }
}
