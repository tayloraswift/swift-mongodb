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
    /// The server response this command expects to receive.
    ///
    /// >   Note:
    ///     By convention, the library refers to a decoded message as a *response*,
    ///     and an undecoded message as a *reply*.
    associatedtype Response:Sendable = Void

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
    @inlinable public static
    func decode(message:MongoWire.Message<ByteBufferView>) throws -> Response
    {
        guard let document:BSON.Document<ByteBufferView> = message.documents.first
        else
        {
            throw Mongo.ReplyError.noDocuments
        }
        if message.documents.count > 1
        {
            throw Mongo.ReplyError.multipleDocuments
        }

        let dictionary:BSON.Dictionary<ByteBufferView> = try .init(fields: try document.parse())
        let ok:Bool = try dictionary["ok"].decode
        {
            switch $0
            {
            case .bool(true), .int32(1), .int64(1), .double(1.0):
                return true
            case .bool(false), .int32(0), .int64(0), .double(0.0):
                return false
            case let unsupported:
                throw Mongo.ReplyError.invalidStatusType(unsupported.type)
            }
        }
        if ok
        {
            return try Self.decode(reply: dictionary)
        }
        else
        {
            throw Mongo.ServerError.init(
                message: dictionary.items["errmsg"]?.as(String.self) ?? "")
        }
    }
}
extension MongoCommand
{
    /// Encodes this command to a BSON document, adding the database, transaction,
    /// and session labels if provided.
    @inlinable public
    func encode(database:Mongo.Database, labels:Mongo.TransactionLabels?) -> BSON.Fields
    {
        //  this is `@inlinable` because we want ``MongoCommand.encode(to:)`` to be inlined
        .init
        {
            self.encode(to: &$0)

            $0["$db"] = database

            guard let labels:Mongo.TransactionLabels
            else
            {
                return
            }

            $0["lsid"] = labels.session

            guard let phase:Mongo.TransactionPhase = labels.transaction.phase
            else
            {
                return
            }

            $0["txnNumber"] = labels.transaction.number
            $0["autocommit"] = false

            guard case .starting = phase
            else
            {
                return
            }

            $0["startTransaction"] = true
        }
    }
}
