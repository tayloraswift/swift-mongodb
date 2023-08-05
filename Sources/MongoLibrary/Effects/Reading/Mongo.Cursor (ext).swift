import MongoDriver

extension Mongo.Cursor:MongoReadEffect
{
    public
    typealias Stride = Int
}
