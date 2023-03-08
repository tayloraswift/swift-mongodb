import BSON

/// A `BSONDSL` is nothing more than a type that supports an ``init(with:)``
/// builder API.
///
/// The specific encoding API vended and encodability protocol used is up to
/// the conforming type.
public
protocol BSONDSL
{
    init()
}
extension BSONDSL where Self:BSONRepresentable<BSON.Document>
{
    @inlinable public
    init()
    {
        self.init(.init())
    }
}
extension BSONDSL
{
    /// Creates an empty instance of this type, and initializes it with the
    /// given closure.
    @inlinable public
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init()
        try populate(&self)
    }
}
