import BSON
import MongoDriver

public
protocol MongoWriteEffect
{
    associatedtype ExecutionPolicy:MongoExecutionPolicy
    associatedtype DeletePlurality:BSONEncodable
    associatedtype UpdatePlurality:BSONEncodable
}
