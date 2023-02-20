extension BSON
{
    /// A list had an invalid number of elements.
    @frozen public
    struct ListShapeError:Equatable, Error
    {
        public
        let count:Int
        public
        let expected:ListShapeCriteria?

        @inlinable public
        init(invalid:Int, expected:ListShapeCriteria? = nil)
        {
            self.count = invalid
            self.expected = expected
        }
    }
}
extension BSON.ListShapeError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self.expected
        {
        case nil:
            return "Invalid element count (\(self.count))."
        
        case .count(let count)?:
            return "Invalid element count (\(self.count)), expected \(count) elements."
        
        case .multiple(of: let stride)?:
            return "Invalid element count (\(self.count)), expected multiple of \(stride)."
        }
    }
}
