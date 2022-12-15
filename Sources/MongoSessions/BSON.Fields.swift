import BSONEncoding

extension BSON.Fields
{
    /// Adds a MongoDB database identifier to this list of fields, under the key [`"$db"`]().
    @usableFromInline mutating
    func add(database:Mongo.Database)
    {
        self["$db"] = database
    }
}
extension BSON.Fields
{
    /// Adds a MongoDB session identifier to this list of fields, under the key [`"lsid"`]().
    @usableFromInline mutating
    func add(session:Mongo.SessionIdentifier)
    {
        self["lsid"] = session
    }
}
