import BSONEncoding

//  spec:
//  https://github.com/mongodb/specifications/blob/master/source/enumerate-collections.rst

extension Mongo
{
    /// Retrieve information about collections and
    /// [views](https://www.mongodb.com/docs/manual/core/views/) in a database.
    ///
    /// > See:  https://www.mongodb.com/docs/manual/reference/command/listCollections/
    public
    struct ListCollections:Sendable
    {
        public
        let authorizedCollections:Bool?
        public
        let filter:BSON.Fields

        public
        init(authorizedCollections:Bool? = nil, filter:BSON.Fields = .init())
        {
            self.authorizedCollections = authorizedCollections
            self.filter = filter
        }
    }
}
// TODO: ListCollections *should* support timeoutMS...
extension Mongo.ListCollections:MongoCommand
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["listCollections"] = 1 as Int32
        bson["authorizedCollections"] = self.authorizedCollections
        bson["filter", elide: true] = self.filter
    }

    public
    typealias Response = Mongo.Cursor<Mongo.CollectionMetadata>
}
// TODO: `listCollections` should by a streamable command...
extension Mongo.ListCollections:MongoDatabaseCommand
{
}
// FIXME: ListCollections *can* run on a secondary,
// but *should* run on a primary.
extension Mongo.ListCollections:MongoReadOnlyCommand
{
}
extension Mongo.ListCollections:MongoImplicitSessionCommand
{
}
extension Mongo.ListCollections:MongoTransactableCommand
{
    @inlinable public
    var readConcern:Mongo.ReadConcern?
    {
        nil
    }
}
