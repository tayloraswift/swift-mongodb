import BSONEncoding
import Durations

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
        let timeout:Milliseconds?
        public
        let stride:Int
        public
        let filter:BSON.Fields

        public
        init(authorizedCollections:Bool? = nil,
            timeout:Milliseconds? = nil,
            stride:Int,
            filter:BSON.Fields = .init())
        {
            self.authorizedCollections = authorizedCollections
            self.timeout = timeout
            self.stride = stride
            self.filter = filter
        }
    }
}
// TODO: ListCollections *should* support timeoutMS...
extension Mongo.ListCollections:MongoDatabaseCommand, MongoCommand
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["listCollections"] = 1 as Int32
        bson["cursor"] = .init
        {
            $0["batchSize"] = self.stride
        }
        bson["maxTimeMS"] = self.timeout
        bson["authorizedCollections"] = self.authorizedCollections
        bson["filter", elide: true] = self.filter
    }

    public
    typealias Response = Mongo.Cursor<Mongo.CollectionMetadata>
}
extension Mongo.ListCollections:MongoQuery
{
    public
    typealias Element = Mongo.CollectionMetadata
    
    @inlinable public
    var tailing:Mongo.Tailing?
    {
        nil
    }
}
// TODO: `listCollections` should by a streamable command...
// FIXME: ListCollections *can* run on a secondary,
// but *should* run on a primary.
// extension Mongo.ListCollections:MongoReadOnlyCommand
// {
// }
extension Mongo.ListCollections:MongoImplicitSessionCommand
{
}
extension Mongo.ListCollections:MongoTransactableCommand
{
}
