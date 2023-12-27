import BSON

extension Mongo
{
    public
    typealias WriteEffect = _MongoWriteEffect
}

/// The name of this protocol is ``Mongo.WriteEffect``.
public
protocol _MongoWriteEffect
{
    associatedtype DeletePlurality:BSONEncodable
    associatedtype UpdatePlurality:BSONEncodable
    associatedtype ExecutionPolicy
}
