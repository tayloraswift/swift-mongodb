import BSONEncoding
import MongoDriver

extension Mongo
{
    public
    struct DropIndexes:Sendable
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
extension Mongo.DropIndexes:MongoImplicitSessionCommand, MongoTransactableCommand, MongoCommand
{
    @inlinable public static
    var type:Mongo.CommandType { .dropIndexes }
}
/// The ``Index`` field is mandatory, but it can have many types, so it uses
/// a subscript-assignment interface.
extension Mongo.DropIndexes
{
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(writeConcern: writeConcern, fields: Self.type(collection))
        try populate(&self)
    }
}
extension Mongo.DropIndexes
{
    @inlinable public
    subscript(key:Index) -> String?
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
    subscript(key:Index) -> [String]
    {
        get
        {
            []
        }
        set(value)
        {
            self.fields.append(key, value)
        }
    }
    @inlinable public
    subscript(key:Index) -> Mongo.PredicateDocument?
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
