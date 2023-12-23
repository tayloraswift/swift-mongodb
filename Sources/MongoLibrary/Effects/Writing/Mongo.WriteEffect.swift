import BSON
import MongoDriver

extension Mongo
{
    public
    typealias WriteEffect = _MongoWriteEffect
}

/// The name of this protocol is ``Mongo.WriteEffect``.
public
protocol _MongoWriteEffect
{
    associatedtype ExecutionPolicy:MongoExecutionPolicy
    associatedtype DeletePlurality:BSONEncodable
    associatedtype UpdatePlurality:BSONEncodable
}
