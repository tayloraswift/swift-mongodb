/// The type of database a ``MongoCommand`` can be run against.
public
protocol MongoCommandDatabase
{
    var name:String { get }
}
