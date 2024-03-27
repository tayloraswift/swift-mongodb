import BSON

extension Mongo.Cursor:Mongo.ReadEffect
{
    public
    typealias Stride = Int
    public
    typealias Batch = Mongo.CursorBatch<BatchElement>
}
