import BSON
import MongoCommands

extension Mongo
{
    public
    protocol IterableCommand<Element>:Command where Response == CursorBatch<Element>
    {
        associatedtype Element:BSONDecodable & Sendable

        var tailing:Tailing? { get }
        var stride:Int? { get }
    }
}
