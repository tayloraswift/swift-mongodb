import BSON

extension Mongo
{
    public
    typealias Failpoint = _MongoFailpoint
}

/// The name of this protocol is ``Mongo.Failpoint``.
public
protocol _MongoFailpoint:BSONEncodable, Sendable
{
    static
    var name:String { get }
}
