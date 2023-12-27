import BSON
import MongoCommands

extension Mongo
{
    public
    typealias IterableCommand = _MongoIterableCommand
}

@available(*, deprecated, renamed: "Mongo.IterableCommand")
public
typealias MongoIterableCommand = Mongo.IterableCommand

public
protocol _MongoIterableCommand<Element>:Mongo.Command
    where Response == Mongo.CursorBatch<Element>
{
    associatedtype Element:BSONDecodable & Sendable

    var tailing:Mongo.Tailing? { get }
    var stride:Int? { get }
}
