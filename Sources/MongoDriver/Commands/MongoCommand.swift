import BSONDecoding
import BSONEncoding
import Durations
import MongoWire
import NIOCore

/// A type that can encode a MongoDB command document. All command types
/// (and command protocols) eventually inherit from this protocol.
public
protocol MongoCommand<Response>:Sendable
{
    associatedtype WriteConcern = Never
    associatedtype ReadConcern = Never

    /// The type of database this command can be run against.
    associatedtype Database:MongoCommandDatabase = Mongo.Database

    /// The server response this command expects to receive.
    ///
    /// >   Note:
    ///     By convention, the library refers to a decoded message as a *response*,
    ///     and an undecoded message as a *reply*.
    associatedtype Response:Sendable

    var writeConcernLabel:Mongo.WriteConcern? { get }
    var writeConcern:WriteConcern? { get }

    var readConcernLabel:Mongo.ReadConcern?? { get }
    var readConcern:ReadConcern? { get }

    var timeout:Mongo.MaxTime? { get }

    /// The payload of this command.
    var payload:Mongo.Payload? { get }
    
    /// The opaque fields of this command. Not all conforming types will encode
    /// all of their fields to this property; some may have fields (such as
    /// `readConcern` or `maxTimeMS`) that are recognized by the driver and added
    /// later during the command execution process.
    var fields:BSON.Fields { get }

    /// The official name of this command, in the MongoDB specification. It
    /// always begins with a lowercase letter, and usually resembles the name
    /// of the command type.
    static
    var name:String { get }

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
extension MongoCommand
{
    /// Returns [`nil`]().
    @inlinable public
    var payload:Mongo.Payload?
    {
        nil
    }
    @inlinable public
    var timeout:Mongo.MaxTime?
    {
        .auto
    }
}
extension MongoCommand where ReadConcern == Mongo.ReadConcern
{
    @inlinable public
    var readConcernLabel:Mongo.ReadConcern??
    {
        self.readConcern
    }
}
extension MongoCommand where ReadConcern == Never
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
extension MongoCommand where WriteConcern == Mongo.WriteConcern
{
    @inlinable public
    var writeConcernLabel:Mongo.WriteConcern?
    {
        self.writeConcern
    }
}
extension MongoCommand where WriteConcern == Never
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
    public __consuming
    func encode(database:Database, labels:Mongo.SessionLabels?,
        by deadline:ContinuousClock.Instant) -> MongoWire.Message<[UInt8]>.Sections?
    {
        // do this first, so we never have to access `self` after reading `self.fields`
        let outlined:[MongoWire.Message<[UInt8]>.Outline] =
            self.payload.map { [$0.outline] } ?? []

        let now:ContinuousClock.Instant = .now

        guard now < deadline
        else
        {
            return nil
        }

        let timeout:Milliseconds? = self.timeout.map
        {
            switch $0
            {
            case .auto:
                return .init(truncating: now.duration(to: deadline))
            }
        }

        let body:BSON.Document<[UInt8]> = self.body(database: database,
            timeout: timeout,
            labels: labels)

        return .init(body: body, outlined: outlined)
    }

    private __consuming
    func body(database:Database, timeout:Milliseconds?,
        labels:Mongo.SessionLabels?) -> BSON.Document<[UInt8]>
    {
        var bson:BSON.Fields = self.fields

        bson["$db"] = database.name
        bson["maxTimeMS"] = timeout

        if let labels:Mongo.SessionLabels
        {
            bson["$clusterTime"] = labels.clusterTime
            bson["$readPreference"] = labels.preference
            bson["readConcern"] = labels.readConcern
            bson["writeConcern"] = labels.writeConcern
            bson["lsid"] = labels.session

            switch labels.transaction
            {
            case nil:
                break
            
            case .starting(let number)?:
                bson["startTransaction"] = true
                fallthrough
            
            case .started(let number)?:
                bson["autocommit"] = false
                bson["txnNumber"] = number
            }
        }

        return .init(bson)
    }
}
