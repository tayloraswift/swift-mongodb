extension BSON
{
    /// An efficient interface for checking the shape of a decoded
    /// list at run time.
    @frozen public
    struct ListShape:Hashable, Sendable
    {
        public
        let count:Int

        @inlinable public
        init(count:Int)
        {
            self.count = count
        }
    }
}
extension BSON.ListShape
{
    /// Throws an ``ListShapeError`` if the relevant array does not
    /// contain the specified number of elements.
    @inlinable public
    func expect(count:Int) throws
    {
        guard self.count == count 
        else 
        {
            throw BSON.ListShapeError.init(invalid: self.count, expected: .count(count))
        }
    }
    /// Throws an ``ListShapeError`` if the number of elements in the
    /// relevant array is not a multiple of the specified stride.
    @inlinable public
    func expect(multipleOf stride:Int) throws
    {
        guard self.count.isMultiple(of: stride)
        else 
        {
            throw BSON.ListShapeError.init(invalid: self.count,
                expected: .multiple(of: stride))
        }
    }
    /// Converts a boolean status code into a thrown ``ListShapeError``.
    /// To generate an error, return false from the closure.
    @inlinable public 
    func expect(that predicate:(_ count:Int) throws -> Bool) throws
    {
        guard try predicate(self.count)
        else 
        {
            throw BSON.ListShapeError.init(invalid: self.count)
        }
    }
}
