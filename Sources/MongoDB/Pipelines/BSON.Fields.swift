import BSON

extension BSON.Fields
{
    //  We need this because swift cannot use leading dot syntax if the
    //  type context is both optional and generic. (It can use leading-dot
    //  syntax if the type context is generic but non-optional.)
    @inlinable public
    subscript(key:String) -> Mongo.Expression?
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:Mongo.Expression
            {
                self.append(key: key, with: value.encode(to:))
            }
        }
    }
}
