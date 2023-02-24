/// The type of database a ``MongoSessionCommand`` can be run against.
public
protocol MongoCommandDatabase
{
    var name:String { get }
}
