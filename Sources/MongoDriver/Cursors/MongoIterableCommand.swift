import Durations
import MongoSchema

public
protocol MongoIterableCommand<Element>:MongoCommand
    where Response == Mongo.Cursor<Element>
{
    associatedtype Element:MongoDecodable

    var tailing:Mongo.Tailing? { get }
    var stride:Int { get }
}
