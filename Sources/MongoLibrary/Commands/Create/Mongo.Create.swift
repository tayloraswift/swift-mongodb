import BSONEncoding
import MongoDriver

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
extension Mongo.Create
{
    private
    init(collection:Mongo.Collection,
        writeConcern:WriteConcern?,
        with populate:(inout BSON.DocumentEncoder<BSON.Key>) -> ())
    {
        self.init(writeConcern: writeConcern, fields: Self.type(collection, then: populate))
    }
}
extension Mongo.Create:MongoImplicitSessionCommand, MongoTransactableCommand, MongoCommand
{
    @inlinable public static
    var type:Mongo.CommandType { .create }
}
extension Mongo.Create
{
    public
    init(collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil)
    {
        self.init(writeConcern: writeConcern, fields: Self.type(collection))
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
        {
            $0["timeseries"] = timeseries
        }
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
        {
            // don’t elide pipeline, it should always be there
            $0["viewOn"] = view.collection
            $0["pipeline"] = view.pipeline
        }
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
            self.fields.push(key, value)
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
            self.fields.push(key, value)
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
            self.fields.push(key, value)
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
            self.fields.push(key, value)
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
            self.fields.push(key, value)
        }
    }
}
