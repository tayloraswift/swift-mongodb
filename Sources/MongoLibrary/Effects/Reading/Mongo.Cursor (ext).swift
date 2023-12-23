import BSON
import MongoDriver

extension Mongo.Cursor:Mongo.ReadEffect
{
    public
    typealias Stride = Int
}
