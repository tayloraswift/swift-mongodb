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
extension Mongo.ListCollections:MongoIterableCommand
{
    public
    typealias Response = Mongo.Cursor<Mongo.CollectionMetadata>
    public
    typealias Element = Mongo.CollectionMetadata
    
    @inlinable public
    var tailing:Mongo.Tailing?
    {
        nil
    }
}
extension Mongo.ListCollections:MongoImplicitSessionCommand,
    MongoTransactableCommand,
    MongoCommand
{
    /// The string [`"listCollections"`]().
    @inlinable public static
    var name:String
    {
        "listCollections"
    }
    
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson[Self.name] = 1 as Int32
        bson["cursor"] = .init
        {
            $0["batchSize"] = self.stride
        }
        bson["maxTimeMS"] = self.timeout
        bson["authorizedCollections"] = self.authorizedCollections
        bson["filter", elide: true] = self.filter
    }

}
// TODO: `listCollections` should by a streamable command...
// FIXME: ListCollections *can* run on a secondary,
// but *should* run on a primary.
