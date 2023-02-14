import BSONEncoding

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
        var fields:BSON.Fields

        private
        init(writeConcern:WriteConcern?,
            fields:BSON.Fields)
        {
            self.writeConcern = writeConcern
            self.fields = fields
        }
    }
}
extension Mongo.Create
{
    private
    init(writeConcern:WriteConcern?,
        with populate:(inout BSON.Fields) throws -> ()) rethrows
    {
        self.init(writeConcern: writeConcern, fields: try .init(with: populate))
    }
}
extension Mongo.Create:MongoImplicitSessionCommand, MongoTransactableCommand, MongoCommand
{
    /// The string [`"create"`]().
    @inlinable public static
    var name:String
    {
        "create"
    }
}

extension Mongo.Create
{
    public
    init(collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil)
    {
        self.init(writeConcern: writeConcern)
        {
            $0[Self.name] = collection
        }
    }
    @inlinable public
    init(collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection: collection, writeConcern: writeConcern)
        try populate(&self)
    }
}
extension Mongo.Create<Mongo.Timeseries>
{
    public
    init(collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        timeseries:Mongo.Timeseries)
    {
        self.init(collection: collection, writeConcern: writeConcern)
        self.fields["timeseries"] = timeseries
    }
    @inlinable public
    init(collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        timeseries:Mongo.Timeseries,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection: collection, writeConcern: writeConcern, timeseries: timeseries)
        try populate(&self)
    }
}
extension Mongo.Create<Mongo.CollectionView>
{
    public
    init(collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        view:Mongo.CollectionView)
    {
        self.init(collection: collection, writeConcern: writeConcern)
        // don’t elide pipeline, it should always be there
        self.fields["viewOn"] = view.collection
        self.fields["pipeline"] = view.pipeline
    }
    @inlinable public
    init(collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        view:Mongo.CollectionView,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection: collection, writeConcern: writeConcern, view: view)
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
            self.fields[key.rawValue] = value
        }
    }

    @inlinable public
    subscript(key:StorageEngine) -> BSON.Fields?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[key.rawValue] = value
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
            if case (let size, let max)? = value
            {
                self.fields["capped"] = true
                self.fields["size"] = size
                self.fields["max"] = max
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
            self.fields[key.rawValue] = value
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
            self.fields[key.rawValue] = value
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
            self.fields[key.rawValue] = value
        }
    }
}
