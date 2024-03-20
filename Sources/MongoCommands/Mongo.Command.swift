import BSON
import MongoABI

extension Mongo
{
    /// A type that represents a MongoDB command. All public command types
    /// (and command protocols) ultimately inherit from this protocol.
    public
    protocol Command<Response>:Sendable
    {
        associatedtype ExecutionPolicy = Once

        associatedtype WriteConcern = Never
        associatedtype ReadConcern = Never

        /// The type of database this command can be run against.
        associatedtype Database:DatabaseType = Mongo.Database

        /// The server response this command expects to receive.
        ///
        /// >   Note:
        ///     By convention, the library refers to a decoded message as a *response*,
        ///     and an undecoded message as a *reply*.
        associatedtype Response:Sendable

        var writeConcernLabel:Mongo.WriteConcern? { get }
        var writeConcern:Self.WriteConcern? { get }

        var readConcernLabel:Mongo.ReadConcern?? { get }
        var readConcern:Self.ReadConcern? { get }

        /// The payload of this command.
        var outline:OutlineVector? { get }

        var timeout:MaxTime? { get }

        /// The opaque fields of this command. Not all conforming types will encode
        /// all of their fields to this property; some may have fields (such as
        /// `readConcern` or `maxTimeMS`) that are recognized by the driver and added
        /// later during the command execution process.
        var fields:BSON.Document { get }

        /// The official name of this command, in the MongoDB specification. It
        /// always begins with a lowercase letter, and usually resembles the name
        /// of the command type.
        static
        var type:CommandType { get }

        /// @import(BSONDecoding)
        /// A hook to decode an untyped server reply to a typed ``Response``.
        /// This is a static function instead of a requirement on ``Response`` to
        /// permit ``Void`` responses.
        ///
        /// Commands with responses conforming to ``BSONDocumentDecodable`` will
        /// receive a default implementation for this requirement.
        static
        func decode(reply:BSON.DocumentDecoder<BSON.Key>) throws -> Response
    }
}
extension Mongo.Command
{
    /// Returns nil.
    @inlinable public
    var outline:Mongo.OutlineVector?
    {
        nil
    }
    @inlinable public
    var timeout:Mongo.MaxTime?
    {
        .auto
    }
}
extension Mongo.Command where ReadConcern == Mongo.ReadConcern
{
    @inlinable public
    var readConcernLabel:Mongo.ReadConcern??
    {
        self.readConcern
    }
}
extension Mongo.Command where ReadConcern == Never
{
    @inlinable public
    var readConcernLabel:Mongo.ReadConcern??
    {
        nil
    }
    @inlinable public
    var readConcern:Never?
    {
        nil
    }
}
extension Mongo.Command where WriteConcern == Mongo.WriteConcern
{
    @inlinable public
    var writeConcernLabel:Mongo.WriteConcern?
    {
        self.writeConcern
    }
}
extension Mongo.Command where WriteConcern == Never
{
    @inlinable public
    var writeConcernLabel:Mongo.WriteConcern?
    {
        nil
    }
    @inlinable public
    var writeConcern:Never?
    {
        nil
    }
}

extension Mongo.Command<Void>
{
    /// Does nothing, ignoring the supplied decoding container.
    @inlinable public static
    func decode(reply _:BSON.DocumentDecoder<BSON.Key>)
    {
    }
}
extension Mongo.Command where Response:BSONDocumentDecodable<BSON.Key>
{
    /// Delegates to the ``Response`` type’s ``BSONDocumentDecodable`` conformance.
    @inlinable public static
    func decode(reply:BSON.DocumentDecoder<BSON.Key>) throws -> Response
    {
        try .init(bson: reply)
    }
}
