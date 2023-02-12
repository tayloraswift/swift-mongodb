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
        let stride:Int

        public
        var fields:BSON.Fields

        public
        init(authorizedCollections:Bool? = nil,
            stride:Int,
            filter:Mongo.PredicateDocument = [:])
        {
            self.stride = stride
            self.fields = .init
            {
                $0[Self.name] = 1 as Int32
                $0["cursor"] = .init
                {
                    $0["batchSize"] = stride
                }
                $0["authorizedCollections"] = authorizedCollections
                $0["filter", elide: true] = filter
            }
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
}
// FIXME: ListCollections *can* run on a secondary,
// but *should* run on a primary.
