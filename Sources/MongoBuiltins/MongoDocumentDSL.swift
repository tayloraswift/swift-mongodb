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
extension MongoDocumentDSL
    where Self:ExpressibleByDictionaryLiteral, Key == Never, Value == Never
{
    @inlinable public
    init(dictionaryLiteral:(Never, Never)...)
    {
        //  Weirdly, if we try to call `Self.init`, this will call itself instead...
        self.init(.init())
    }
}
