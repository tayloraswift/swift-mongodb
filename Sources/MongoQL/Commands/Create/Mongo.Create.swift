import BSON

extension Mongo
{
    /// Explicitly creates a collection or view.
    ///
    /// > See:  https://www.mongodb.com/docs/manual/reference/command/create/
    public
    struct Create<Mode>:Sendable
    {
        public
        let writeConcern:WriteConcern?

        public
        var fields:BSON.Document

        private
        init(writeConcern:WriteConcern?,
            fields:BSON.Document)
        {
            self.writeConcern = writeConcern
            self.fields = fields
        }
    }
}
extension Mongo.Create:Mongo.Command
{
    @inlinable public static
    var type:Mongo.CommandType { .create }
}
extension Mongo.Create
{
    public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil)
    {
        self.init(writeConcern: writeConcern, fields: Self.type(collection))
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection, writeConcern: writeConcern)
        try populate(&self)
    }
}
extension Mongo.Create<Mongo.Timeseries>
{
    public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        timeseries:Mongo.Timeseries)
    {
        self.init(writeConcern: writeConcern, fields: Self.type(collection))
        self.fields[BSON.Key.self]["timeseries"] = timeseries
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        timeseries:Mongo.Timeseries,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection, writeConcern: writeConcern, timeseries: timeseries)
        try populate(&self)
    }
}
extension Mongo.Create<Mongo.CollectionView>
{
    public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        view:Mongo.CollectionView)
    {
        self.init(writeConcern: writeConcern, fields: Self.type(collection))
            // don’t elide pipeline, it should always be there
        ;
        {
            $0["viewOn"] = view.collection
            $0["pipeline"] = view.pipeline
        } (&self.fields[BSON.Key.self])
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        view:Mongo.CollectionView,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection, writeConcern: writeConcern, view: view)
        try populate(&self)
    }
}

extension Mongo.Create
{
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
    subscript(key:StorageEngine) -> BSON.Document?
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

extension Mongo.Create<Mongo.Collection>
{
    @inlinable public
    subscript(key:Cap) -> (size:Int, max:Int?)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case (let size, let max)? = value
            {
                true.encode(to: &self.fields[with: "capped" as BSON.Key])
                size.encode(to: &self.fields[with: "size" as BSON.Key])
                max?.encode(to: &self.fields[with: "max" as BSON.Key])
            }
        }
    }

    @inlinable public
    subscript(key:ValidationAction) -> Mongo.ValidationAction?
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
    subscript(key:ValidationLevel) -> Mongo.ValidationLevel?
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
    subscript(key:Validator) -> Mongo.PredicateDocument?
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
