import Durations
import MongoSchema

public
protocol MongoQuery<Element>:MongoDatabaseCommand, MongoSessionCommand
    where Response == Mongo.Cursor<Element>
{
    associatedtype Element:MongoDecodable

    var tailing:Mongo.Tailing? { get }
    var stride:Int { get }
}
