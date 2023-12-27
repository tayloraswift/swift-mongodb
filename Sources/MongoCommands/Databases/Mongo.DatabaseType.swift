extension Mongo
{
    /// The type of database a ``Mongo.Command`` can be run against.
    public
    typealias DatabaseType = _MongoDatabaseType
}

@available(*, deprecated, renamed: "Mongo.DatabaseType")
public
typealias MongoCommandDatabase = Mongo.DatabaseType

public
protocol _MongoDatabaseType
{
    var name:String { get }
}
