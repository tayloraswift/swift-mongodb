import BSON
import BSONDSL

extension Mongo.Namespaced<Mongo.Collection>
{
    public
    var document:BSON.Fields
    {
        .init
        {
            $0["db"] = self.database
            $0["coll"] = self.collection
        }
    }
}
