extension BSON
{
    /// A list had an invalid number of elements.
    @frozen public
    struct ArrayShapeError:Equatable, Error
    {
        public
        let count:Int
        public
        let expected:ArrayShapeCriteria?

        @inlinable public
        init(invalid:Int, expected:ArrayShapeCriteria? = nil)
        {
            self.count = invalid
            self.expected = expected
        }
    }
}
extension BSON.ArrayShapeError:CustomStringConvertible
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
