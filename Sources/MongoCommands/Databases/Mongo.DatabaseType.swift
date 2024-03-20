extension Mongo
{
    /// The type of database a ``Mongo.Command`` can be run against.
    public
    protocol DatabaseType
    {
        var name:String { get }
    }
}
