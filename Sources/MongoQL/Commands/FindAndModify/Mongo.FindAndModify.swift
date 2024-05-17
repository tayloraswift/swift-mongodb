import BSON

extension Mongo
{
    public
    struct FindAndModify<Effect>:Sendable where Effect:Mongo.ModificationEffect
    {
        public
        let writeConcern:WriteConcern?
        public
        var fields:BSON.Document

        @usableFromInline internal
        init(writeConcern:WriteConcern?,
            fields:BSON.Document)
        {
            self.writeConcern = writeConcern
            self.fields = fields
        }
    }
}
extension Mongo.FindAndModify:Mongo.Command
{
    @inlinable public static
    var type:Mongo.CommandType { .findAndModify }

    public
    typealias ExecutionPolicy = Mongo.Retry

    public
    typealias Response = (value:Effect.Value, upserted:Effect.ID?)

    @inlinable public static
    func decode(reply bson:BSON.DocumentDecoder<BSON.Key>) throws ->
    (
        value:Effect.Value,
        upserted:Effect.ID?
    )
    {
        (
            try bson["value"].decode(),
            try bson["lastErrorObject"].decode
            {
                try $0["upserted"]?.decode()
            }
        )
    }
}
extension Mongo.FindAndModify
{
    public
    init(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        returning phase:Effect.Phase)
    {
        self.init(writeConcern: writeConcern, fields: Self.type(collection)
        {
            $0[Effect.Phase.field] = phase
            $0["upsert"] = Effect.upsert
        })
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        returning phase:Effect.Phase,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection, writeConcern: writeConcern, returning: phase)
        try populate(&self)
    }
}
extension Mongo.FindAndModify
{
    @frozen public
    enum Flag:String, Hashable, Sendable
    {
        case bypassDocumentValidation
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
            value?.encode(to: &self.fields[with: key])
        }
    }
}
extension Mongo.FindAndModify
{
    @frozen public
    enum Collation:String, Hashable, Sendable
    {
        case collation
    }

    @inlinable public
    subscript(key:Collation) -> Mongo.Collation?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.fields[with: key])
        }
    }
}
extension Mongo.FindAndModify
{
    @frozen public
    enum Fields:String, Hashable, Sendable
    {
        case fields
    }

    /// Encodes a projection document.
    @inlinable public
    subscript(key:Fields, yield:(inout Mongo.ProjectionEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.fields[with: key][as: Mongo.ProjectionEncoder.self])
        }
    }

    /// Encodes a projection document from a model type.
    @inlinable public
    subscript<ProjectionDocument>(key:Fields) -> ProjectionDocument?
        where ProjectionDocument:Mongo.ProjectionEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.fields[with: key][as: Mongo.ProjectionEncoder.self])
        }
    }

    @available(*, deprecated)
    @inlinable public
    subscript(key:Fields) -> Mongo.ProjectionDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.fields[with: key])
        }
    }
}
extension Mongo.FindAndModify
{
    @frozen public
    enum Hint:String, Hashable, Sendable
    {
        case hint
    }

    @inlinable public
    subscript(key:Hint) -> String?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.fields[with: key])
        }
    }

    @inlinable public
    subscript(key:Hint, yield:(inout Mongo.SortEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.fields[with: key][as: Mongo.SortEncoder.self])
        }
    }

    @available(*, deprecated, message: "use the functional subscript instead")
    @inlinable public
    subscript(key:Hint) -> Mongo.SortDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.fields[with: key])
        }
    }
}
extension Mongo.FindAndModify
{
    @frozen public
    enum Let:String, Hashable, Sendable
    {
        case `let`
    }

    @inlinable public
    subscript(key:Let) -> Mongo.LetDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.fields[with: key])
        }
    }
}
extension Mongo.FindAndModify
{
    @frozen public
    enum Query:String, Hashable, Sendable
    {
        case query
    }

    @inlinable public
    subscript(key:Query, yield:(inout Mongo.PredicateEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.fields[with: key][as: Mongo.PredicateEncoder.self])
        }
    }

    @available(*, deprecated, message: "use the functional subscript instead")
    @inlinable public
    subscript(key:Query) -> Mongo.PredicateDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.fields[with: key])
        }
    }
}
extension Mongo.FindAndModify
{
    @frozen public
    enum Sort:String, Hashable, Sendable
    {
        case sort
    }

    @inlinable public
    subscript(key:Sort, yield:(inout Mongo.SortEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.fields[with: key][as: Mongo.SortEncoder.self])
        }
    }

    @available(*, deprecated, message: "use the functional subscript instead")
    @inlinable public
    subscript(key:Sort) -> Mongo.SortDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.fields[with: key])
        }
    }
}
extension Mongo.FindAndModify where Effect.Upsert == Bool
{
    @frozen public
    enum Update:String, Hashable, Sendable
    {
        case update
    }

    @inlinable public
    subscript(key:Update, yield:(inout Mongo.UpdateEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.fields[with: key][as: Mongo.UpdateEncoder.self])
        }
    }

    @available(*, deprecated, message: "use the functional subscript instead")
    @inlinable public
    subscript(key:Update) -> Mongo.UpdateDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.fields[with: key])
        }
    }

    @inlinable public
    subscript(key:Update, yield:(inout Mongo.PipelineEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.fields[with: key][as: Mongo.PipelineEncoder.self])
        }
    }

    @available(*, deprecated, message: "use the functional subscript instead")
    @inlinable public
    subscript(key:Update) -> Mongo.Pipeline?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.fields[with: key])
        }
    }

    @inlinable public
    subscript<Replacement>(key:Update) -> Replacement?
        where Replacement:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.fields[with: key])
        }
    }
}
extension Mongo.FindAndModify where Effect.Upsert == Bool
{
    @frozen public
    enum ArrayFilters:String, Hashable, Sendable
    {
        case arrayFilters
    }

    @inlinable public
    subscript(key:ArrayFilters, yield:(inout Mongo.PredicateListEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.fields[with: key][as: Mongo.PredicateListEncoder.self])
        }
    }

    @available(*, deprecated, message: "use the functional subscript instead")
    @inlinable public
    subscript(key:ArrayFilters) -> Mongo.PredicateList?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.fields[with: key])
        }
    }

    @available(*, deprecated, message: "use the functional subscript instead")
    @inlinable public
    subscript(key:ArrayFilters) -> [Mongo.PredicateDocument]
    {
        get
        {
            []
        }
        set(value)
        {
            value.encode(to: &self.fields[with: key])
        }
    }
}
