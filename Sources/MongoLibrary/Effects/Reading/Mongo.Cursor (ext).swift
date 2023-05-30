import MongoDriver

extension Mongo.Cursor:MongoReadEffect
{
    public
    typealias Response = Self
    public
    typealias Tailing = Mongo.Tailing
    public
    typealias Stride = Int
}
