import BSONSchema
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
    public
    typealias Response = Mongo.ReplicaSetConfiguration

    // we need to provide this witness, to prevent the default implementation
    // from running (which will fail to unnest one level of 'config')
    public static
    func decode(reply bson:BSON.Dictionary<ByteBufferView>)
        throws -> Mongo.ReplicaSetConfiguration
    {
        try self._decode(reply: bson)
    }
    @inlinable public static
    func decode(reply bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>)
        throws -> Mongo.ReplicaSetConfiguration
    {
        try self._decode(reply: bson)
    }
    @inlinable public static
    func _decode(reply bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>)
        throws -> Mongo.ReplicaSetConfiguration
    {
        return try bson["config"].decode(to: Mongo.ReplicaSetConfiguration.self)
    }
    
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["replSetGetConfig"] = 1 as Int32
    }
}
// extension Mongo.ReplicaSetGetConfiguration:MongoReadOnlyCommand
// {
// }
extension Mongo.ReplicaSetGetConfiguration:MongoImplicitSessionCommand
{
}
