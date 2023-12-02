import BSON
import MongoSchema
import NIOCore

extension Mongo
{
    public
    struct ReplicaSetGetConfiguration:Sendable
    {
        public
        init()
        {
        }
    }
}
extension Mongo.ReplicaSetGetConfiguration:MongoCommand
{
    @inlinable public static
    var type:Mongo.CommandType { .replicaSetGetConfiguration }

    /// `ReplicaSetGetConfiguration` must be run against to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    public
    typealias Response = Mongo.ReplicaSetConfiguration

    // we need to provide this witness, to prevent the default implementation
    // from running (which will fail to unnest one level of 'config')
    public static
    func decode(reply bson:BSON.DocumentDecoder<BSON.Key, ByteBufferView>)
        throws -> Mongo.ReplicaSetConfiguration
    {
        try bson["config"].decode(to: Mongo.ReplicaSetConfiguration.self)
    }
    public
    var fields:BSON.Document
    {
        Self.type(1 as Int32)
    }
}
extension Mongo.ReplicaSetGetConfiguration:MongoImplicitSessionCommand
{
}
