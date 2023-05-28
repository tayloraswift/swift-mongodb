import MongoDriver

extension Mongo.Cursor:MongoBatchingMode
{
    public
    typealias Response = Self
    public
    typealias Tailing = Mongo.Tailing
    public
    typealias Stride = Int
}
