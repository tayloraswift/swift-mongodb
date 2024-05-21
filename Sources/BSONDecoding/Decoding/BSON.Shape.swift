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
    /// Returns the quotient if the number of elements in the relevant collection is a multiple
    /// of the specified stride, or throws a ``ShapeError`` otherwise.
    /// If the stride is zero, this method also throws a ``ShapeError``, unless the length is
    /// zero as well.
    @inlinable public
    func expect(multipleOf stride:Int) throws -> Int
    {
        if  self.length == 0
        {
            return 0
        }

        guard stride > 0,
        case (let count, remainder: 0) = self.length.quotientAndRemainder(dividingBy: stride)
        else
        {
            throw BSON.ShapeError.init(invalid: self.length, expected: .multiple(of: stride))
        }

        return count
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
