import BSON

extension Mongo
{
    @frozen public
    struct ChangeStreamEncoder:Sendable
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<BSON.Key>

        @inlinable internal
        init(bson:BSON.DocumentEncoder<BSON.Key>)
        {
            self.bson = bson
        }
    }
}
extension Mongo.ChangeStreamEncoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output)
    {
        self.init(bson: .init(output))
    }

    @inlinable public consuming
    func move() -> BSON.Output { self.bson.move() }

    @inlinable public static
    var frame:BSON.DocumentFrame { .document }
}

extension Mongo.ChangeStreamEncoder
{
    @frozen public
    enum Flag:String, Sendable
    {
        case allChangesForCluster
        case showExpandedEvents
    }

    @inlinable public
    subscript(key:Flag) -> Bool?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}

extension Mongo.ChangeStreamEncoder
{
    @frozen public
    enum FullDocument:String, Sendable
    {
        case fullDocument

        @frozen public
        enum Option:String, BSONDecodable, BSONEncodable, Sendable
        {
            case `default`
            case required
            case updateLookup
            case whenAvailable
        }
    }

    @inlinable public
    subscript(key:FullDocument) -> FullDocument.Option?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}

extension Mongo.ChangeStreamEncoder
{
    @frozen public
    enum FullDocumentBeforeChange:String, Sendable
    {
        case fullDocumentBeforeChange

        @frozen public
        enum Option:String, BSONDecodable, BSONEncodable, Sendable
        {
            case off
            case whenAvailable
            case required
        }
    }

    @inlinable public
    subscript(key:FullDocumentBeforeChange) -> FullDocumentBeforeChange.Option?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}

extension Mongo.ChangeStreamEncoder
{
    @frozen public
    enum ResumeToken:String, Sendable
    {
        case resumeAfter
        case startAfter
    }

    @inlinable public
    subscript(key:ResumeToken) -> Mongo.ChangeEventIdentifier?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}

extension Mongo.ChangeStreamEncoder
{
    @frozen public
    enum StartAtOperationTime:String, Sendable
    {
        case startAtOperationTime
    }

    @inlinable public
    subscript(key:StartAtOperationTime) -> BSON.Timestamp?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
