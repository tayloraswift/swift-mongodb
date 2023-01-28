import BSONEncoding

extension Mongo
{
    public
    enum Output:Sendable
    {
        case merge(BSON.Fields)
        case out(Mongo.Database? = nil, Mongo.Collection)
    }
}
