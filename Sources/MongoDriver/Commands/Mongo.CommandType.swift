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
        case createIndexes
        case commitTransaction
        case configureFailpoint = "configureFailPoint"
        case delete
        case drop
        case dropDatabase
        case dropIndexes
        case endSessions
        case explain
        case find
        case findAndModify
        case fsync
        case fsyncUnlock
        case getMore
        case hello
        case insert
        case killCursors
        case listCollections
        case listDatabases
        case listIndexes
        case modifyCollection = "collMod"
        case ping
        case refreshSessions
        case replicaSetGetConfiguration = "replSetGetConfig"
        case renameCollection
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
