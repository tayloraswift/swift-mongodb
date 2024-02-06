import BSON

extension Mongo
{
    /// An `EncodableDocument` is nothing more than a type that supports an ``init(with:)``
    /// builder API.
    ///
    /// The specific encoding API vended and encodability protocol used is up to the conforming
    /// type.
    public
    typealias EncodableDocument = _MongoEncodableDocument
}

/// The name of this protocol is ``Mongo.EncodableDocument``.
public
protocol _MongoEncodableDocument:BSONRepresentable<BSON.Document>, BSONDecodable, BSONEncodable
{
    associatedtype Encoder = Self
}
extension Mongo.EncodableDocument
{
    @inlinable public
    init()
    {
        self.init(.init())
    }
}
//  Legacy API
extension Mongo.EncodableDocument where Encoder == Self
{
    @inlinable public
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init()
        try populate(&self)
    }
}
extension Mongo.EncodableDocument where Encoder:BSON.Encoder
{
    /// Creates an empty instance of this type, and initializes it with the
    /// given closure.
    @inlinable public
    init(with populate:(inout Encoder) throws -> ()) rethrows
    {
        var bson:BSON.Document = .init()
        try populate(&bson.output[as: Encoder.self])
        self.init(bson)
    }
}
extension Mongo.EncodableDocument
    where Self:ExpressibleByDictionaryLiteral, Key == Never, Value == Never
{
    @inlinable public
    init(dictionaryLiteral:(Never, Never)...)
    {
        //  Weirdly, if we try to call `Self.init`, this will call itself instead...
        self.init(.init())
    }
}
