extension BSON
{
    /// A decoder failed to cast a variant to an expected value type.
    @frozen public
    struct TypecastError<Value>:Equatable, Error
    {
        public
        let variant:AnyType

        @inlinable public
        init(invalid variant:AnyType)
        {
            self.variant = variant
        }
    }
}
extension BSON.TypecastError:CustomStringConvertible
{
    public
    var description:String
    {
        "cannot cast variant of type '\(self.variant)' to type '\(Value.self)'"
    }
}
