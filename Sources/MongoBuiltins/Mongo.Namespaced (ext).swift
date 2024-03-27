import BSON
import MongoABI

extension Mongo.Namespaced<Mongo.Collection>
{
    public
    var document:BSON.Document
    {
        .init(BSON.Key.self)
        {
            $0["db"] = self.database
            $0["coll"] = self.collection
        }
    }
}
