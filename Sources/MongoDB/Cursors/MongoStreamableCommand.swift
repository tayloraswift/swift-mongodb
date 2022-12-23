import Durations
import MongoSchema

public
protocol MongoStreamableCommand<Element>:MongoDatabaseCommand, MongoImplicitSessionCommand
    where Response == Mongo.Cursor<Element>
{
    associatedtype Element:MongoDecodable

    var timeout:Milliseconds? { get }
    var stride:Int { get }
}
