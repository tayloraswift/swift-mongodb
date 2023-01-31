import BSONSchema

public
protocol MongoAccumulatorDSL:BSONDSL where Subdocument == Never
{
}
extension MongoAccumulatorDSL
{
    @inlinable public
    subscript(key:String) -> MongoAccumulator?
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:MongoAccumulator
            {
                self.append(key: key, with: value.encode(to:))
            }
        }
    }
}
