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
