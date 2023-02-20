import BSONDecoding
import Durations

public
protocol MongoIterableCommand<Element>:MongoCommand
    where Response == Mongo.Cursor<Element>
{
    associatedtype Element:BSONDecodable & Sendable

    var tailing:Mongo.Tailing? { get }
    var stride:Int { get }
}
