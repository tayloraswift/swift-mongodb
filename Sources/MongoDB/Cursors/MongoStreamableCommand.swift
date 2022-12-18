import MongoSchema

public
protocol MongoStreamableCommand<Element>:MongoDatabaseCommand, MongoImplicitSessionCommand
    where Response == Mongo.Cursor<Element>
{
    associatedtype Element:MongoDecodable

    var timeout:Mongo.Milliseconds? { get }
    var stride:Int { get }
}
