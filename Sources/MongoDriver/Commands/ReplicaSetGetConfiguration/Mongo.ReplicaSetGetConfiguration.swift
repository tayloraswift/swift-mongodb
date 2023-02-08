import BSONDecoding
import BSONEncoding
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
    /// `ReplicaSetGetConfiguration` must be sent to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

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
    
    /// The string [`"replSetGetConfig"`]().
    @inlinable public static
    var name:String
    {
        "replSetGetConfig"
    }

    public
    var fields:BSON.Fields
    {
        .init
        {
            $0[Self.name] = 1 as Int32
        }
    }
}
extension Mongo.ReplicaSetGetConfiguration:MongoImplicitSessionCommand
{
}
