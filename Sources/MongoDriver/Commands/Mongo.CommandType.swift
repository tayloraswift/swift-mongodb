import BSONDecoding
import BSONEncoding

extension Mongo
{
    public
    enum CommandType:String, Hashable, Sendable
    {
        case abortTransaction
        case aggregate
        case create
        case commitTransaction
        case configureFailpoint = "configureFailPoint"
        case dropDatabase
        case endSessions
        case find
        case fsync
        case fsyncUnlock
        case getMore
        case hello
        case insert
        case killCursors
        case listCollections
        case listDatabases
        case ping
        case refreshSessions
        case replicaSetGetConfiguration = "replSetGetConfig"
        case saslContinue
        case saslStart
        case update
    }
}
extension Mongo.CommandType:BSONDecodable, BSONEncodable
{
}
extension Mongo.CommandType
{
    @inlinable public
    func callAsFunction(_ first:some BSONEncodable,
        then encode:(inout BSON.DocumentEncoder<BSON.Key>) -> () = { _  in }) -> BSON.Document
    {
        .init
        {
            $0[.init(rawValue: self.rawValue)] = first
            encode(&$0)
        }
    }
}
