extension BSON.BinarySubtype
{
    /// Throws a ``BinaryTypecastError`` if this subtype doesn’t match the specified
    /// subtype.
    @inlinable public
    func expect(_ subtype:Self) throws
    {
        if  self != subtype
        {
            throw BSON.BinaryTypecastError.init(invalid: self, expected: subtype)
        }
    }
}
