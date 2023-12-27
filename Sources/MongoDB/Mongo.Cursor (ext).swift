import BSON

extension Mongo.Cursor:Mongo.ReadEffect
{
    public
    typealias Stride = Int
}
