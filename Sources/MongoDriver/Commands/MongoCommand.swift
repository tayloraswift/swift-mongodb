import BSONDecoding
import BSONEncoding
import BSONUnions
import MongoWire
import NIOCore

/// A type that can encode a MongoDB command document. All command types
/// (and command protocols) eventually inherit from this protocol.
public
protocol MongoCommand<Response>:BSONDocumentEncodable, Sendable
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
    /// Commands with responses conforming to ``BSONDictionaryDecodable`` will
    /// receive a default implementation for this requirement.
    static
    func decode(reply:BSON.Dictionary<ByteBufferView>) throws -> Response
}
extension MongoCommand<Void>
{
    /// Does nothing, ignoring the supplied decoding container.
    @inlinable public static
    func decode(reply _:BSON.Dictionary<ByteBufferView>)
    {
    }
}
extension MongoCommand where Response:BSONDictionaryDecodable
{
    /// Delegates to the ``Response`` type’s ``BSONDictionaryDecodable`` conformance.
    @inlinable public static
    func decode(reply:BSON.Dictionary<ByteBufferView>) throws -> Response
    {
        try .init(bson: reply)
    }
}
extension MongoCommand
{
    /// Encodes this command to a BSON document, adding the given database
    /// as a field with the key [`"$db"`]().
    @inlinable public
    func encode(to bson:inout BSON.Fields, database:Database, labels:Mongo.SessionLabels?)
    {
        //  this is `@inlinable` because we want ``MongoCommand.encode(to:)`` to be inlined
        self.encode(to: &bson)

        bson["$db"] = database.name

        guard let labels:Mongo.SessionLabels
        else
        {
            return
        }

        bson["$clusterTime"] = labels.clusterTime
        bson["$readPreference"] = labels.readPreference
        bson["readConcern"] = labels.readConcern
        bson["lsid"] = labels.session

        guard let phase:Mongo.TransactionPhase = labels.transaction.phase
        else
        {
            return
        }

        bson["txnNumber"] = labels.transaction.number
        bson["autocommit"] = false

        guard case .starting = phase
        else
        {
            return
        }

        bson["startTransaction"] = true
    }
}
