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
    /// The string [`"replSetGetConfig"`]().
    @inlinable public static
    var name:String
    {
        "replSetGetConfig"
    }
    
    /// `ReplicaSetGetConfiguration` must be run against to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    public
    typealias Response = Mongo.ReplicaSetConfiguration

    // we need to provide this witness, to prevent the default implementation
    // from running (which will fail to unnest one level of 'config')
    public static
    func decode(reply bson:BSON.DocumentDecoder<String, ByteBufferView>)
        throws -> Mongo.ReplicaSetConfiguration
    {
        try bson["config"].decode(to: Mongo.ReplicaSetConfiguration.self)
    }
    public
    var fields:BSON.Document
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
