extension BSON
{
    /// A list had an invalid number of elements or a binary array
    /// had an invalid number of bytes.
    @frozen public
    struct ShapeError:Equatable, Error
    {
        public
        let length:Int
        public
        let expected:Criteria?

        @inlinable public
        init(invalid:Int, expected:Criteria? = nil)
        {
            self.length = invalid
            self.expected = expected
        }
    }
}
extension BSON.ShapeError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self.expected
        {
        case nil:
            return "Invalid length (\(self.length))."

        case .length(let length)?:
            return "Invalid length (\(self.length)), expected \(length) elements."

        case .multiple(of: let stride)?:
            return "Invalid length (\(self.length)), expected multiple of \(stride)."
        }
    }
}
