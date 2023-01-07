import Durations
import MongoSchema

public
protocol MongoQuery<Element>:MongoCommand
    where Response == Mongo.Cursor<Element>
{
    associatedtype Element:MongoDecodable

    var tailing:Mongo.Tailing? { get }
    var stride:Int { get }
}
