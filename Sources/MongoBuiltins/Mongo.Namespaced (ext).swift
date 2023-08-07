import BSON
import MongoSchema

extension Mongo.Namespaced<Mongo.Collection>
{
    public
    var document:BSON.Document
    {
        .init
        {
            $0["db"] = self.database
            $0["coll"] = self.collection
        }
    }
}
