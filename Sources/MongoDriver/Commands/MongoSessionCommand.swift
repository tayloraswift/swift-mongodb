import BSONEncoding
import Durations
import MongoWire

/// A type that represents a MongoDB command that expects to be executed
/// as part of a ``Session``. All public library commands conform to this
/// protocol, and nearly all public library APIs that accept generic
/// commands use this protocol as a constraint.
public
protocol MongoSessionCommand<Response>:MongoCommand
{
    associatedtype WriteConcern = Never
    associatedtype ReadConcern = Never

    var stack:[(file:StaticString, line:Int)] { get }

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
    var fields:BSON.Document { get }

    /// The official name of this command, in the MongoDB specification. It
    /// always begins with a lowercase letter, and usually resembles the name
    /// of the command type.
    static
    var name:String { get }


}
extension MongoSessionCommand
{
    @inlinable public
    var stack:[(file:StaticString, line:Int)] { [] }
}
extension MongoSessionCommand
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
extension MongoSessionCommand where ReadConcern == Mongo.ReadConcern
{
    @inlinable public
    var readConcernLabel:Mongo.ReadConcern??
    {
        self.readConcern
    }
}
extension MongoSessionCommand where ReadConcern == Never
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
extension MongoSessionCommand where WriteConcern == Mongo.WriteConcern
{
    @inlinable public
    var writeConcernLabel:Mongo.WriteConcern?
    {
        self.writeConcern
    }
}
extension MongoSessionCommand where WriteConcern == Never
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
extension MongoSessionCommand
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

        let body:BSON.DocumentView<[UInt8]> = self.body(database: database,
            timeout: timeout,
            labels: labels)

        return .init(body: body, outlined: outlined)
    }

    private __consuming
    func body(database:Database, timeout:Milliseconds?,
        labels:Mongo.SessionLabels?) -> BSON.DocumentView<[UInt8]>
    {
        var bson:BSON.Document = self.fields

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
