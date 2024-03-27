import BSON
import Durations
import MongoCommands
import MongoWire

extension Mongo.Command
{
    /// Indicates if this command autocommits, meaning it supports
    /// retryable writes.
    @inlinable public static
    var autocommits:Bool
    {
        WriteConcern.self is Mongo.WriteConcern.Type &&
        ExecutionPolicy.self is Mongo.Retry.Type
    }
}
extension Mongo.Command
{
    /// Encodes this command to a BSON document, adding the given database as a field with the
    /// key `"$db"`.
    @usableFromInline __consuming
    func encode(database:Database,
        labels:Mongo.SessionLabels?,
        by deadline:ContinuousClock.Instant) -> Mongo.WireMessage.Sections?
    {
        // do this first, so we never have to access `self` after reading `self.fields`
        let outlined:[Mongo.WireMessage.Outline]? = self.outline.map
        {
            [.init(id: $0.type.rawValue, slice: $0.bson.destination[...])]
        }

        let now:ContinuousClock.Instant = .now

        guard now < deadline
        else
        {
            return nil
        }

        let timeout:Milliseconds?

        switch self.timeout
        {
        case .computed: timeout = .init(truncating: now.duration(to: deadline))
        case .omitted:  timeout = nil
        }

        let body:BSON.Document = self.body(database: database,
            timeout: timeout,
            labels: labels)

        return .init(body: body, outlined: outlined ?? [])
    }

    private consuming
    func body(database:Database,
        timeout:Milliseconds?,
        labels:Mongo.SessionLabels?) -> BSON.Document
    {
        var bson:BSON.Document = self.fields
        ;
        {
            $0["$db"] = database.name
            $0["maxTimeMS"] = timeout

            guard
            let labels:Mongo.SessionLabels
            else
            {
                return
            }

            $0["$clusterTime"] = labels.clusterTime
            $0["$readPreference"] = labels.preference
            $0["readConcern"] = labels.readConcern
            $0["writeConcern"] = labels.writeConcern
            $0["lsid"] = labels.session

            switch labels.transaction
            {
            case nil:
                break

            case .autocommitting(let number)?:
                $0["txnNumber"] = number

            case .starting(let number)?:
                $0["startTransaction"] = true
                fallthrough

            case .started(let number)?:
                $0["autocommit"] = false
                $0["txnNumber"] = number
            }
        } (&bson[BSON.Key.self])

        return bson
    }
}
