import BSONDecoding
import BSONEncoding
import MongoWire
import NIOCore

/// A type that represents a MongoDB command. All command types
/// (and command protocols) ultimately inherit from this protocol.
public
protocol MongoCommand<Response>:Sendable
{
    /// The type of database this command can be run against.
    associatedtype Database:MongoCommandDatabase = Mongo.Database

    /// The server response this command expects to receive.
    ///
    /// >   Note:
    ///     By convention, the library refers to a decoded message as a *response*,
    ///     and an undecoded message as a *reply*.
    associatedtype Response:Sendable

    /// @import(BSONDecoding)
    /// A hook to decode an untyped server reply to a typed ``Response``.
    /// This is a static function instead of a requirement on ``Response`` to
    /// permit ``Void`` responses.
    ///
    /// Commands with responses conforming to ``BSONDocumentDecodable`` will
    /// receive a default implementation for this requirement.
    static
    func decode(
        reply:BSON.DocumentDecoder<BSON.Key, ByteBufferView>) throws -> Response
}
extension MongoCommand<Void>
{
    /// Does nothing, ignoring the supplied decoding container.
    @inlinable public static
    func decode(reply _:BSON.DocumentDecoder<BSON.Key, ByteBufferView>)
    {
    }
}
extension MongoCommand where Response:BSONDocumentDecodable<BSON.Key>
{
    /// Delegates to the ``Response`` type’s ``BSONDocumentDecodable`` conformance.
    @inlinable public static
    func decode(
        reply:BSON.DocumentDecoder<BSON.Key, ByteBufferView>) throws -> Response
    {
        try .init(bson: reply)
    }
}
extension MongoCommand where Self:BSONDocumentEncodable
{
    /// Encodes this command to a BSON document, adding the given database
    /// as a field with the key [`"$db"`]().
    func encode(database:Database,
        by deadline:ContinuousClock.Instant) -> MongoWire.Message<[UInt8]>.Sections?
    {
        let now:ContinuousClock.Instant = .now

        if now < deadline
        {
            var document:BSON.Document = .init(encoding: self)
                document["$db"] = database.name
            return .init(body: .init(document))
        }
        else
        {
            return nil
        }
    }
}
