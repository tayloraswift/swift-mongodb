extension BSON
{
    /// An efficient interface for checking the shape of a decoded
    /// list or binary array at run time.
    @frozen public
    struct Shape:Hashable, Sendable
    {
        public
        let length:Int

        @inlinable public
        init(length:Int)
        {
            self.length = length
        }
    }
}
extension BSON.Shape
{
    /// Throws an ``ShapeError`` if the relevant collection does not
    /// contain the specified number of elements.
    @inlinable public
    func expect(length:Int) throws
    {
        guard self.length == length
        else
        {
            throw BSON.ShapeError.init(invalid: self.length, expected: .length(length))
        }
    }
    /// Throws an ``ShapeError`` if the number of elements in the
    /// relevant collection is not a multiple of the specified stride.
    @inlinable public
    func expect(multipleOf stride:Int) throws
    {
        guard self.length.isMultiple(of: stride)
        else
        {
            throw BSON.ShapeError.init(invalid: self.length,
                expected: .multiple(of: stride))
        }
    }
    /// Converts a boolean status code into a thrown ``ShapeError``.
    /// To raise an error, return false from the closure.
    @inlinable public
    func expect(that predicate:(_ length:Int) throws -> Bool) throws
    {
        guard try predicate(self.length)
        else
        {
            throw BSON.ShapeError.init(invalid: self.length)
        }
    }
}
