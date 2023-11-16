extension BSON
{
    /// A binary view was sliced from a malformed storage buffer.
    @frozen public
    struct BinaryViewError:Equatable, Error
    {
        /// What the input should have yielded.
        public
        let expected:Expectation

        @inlinable public
        init(expected:Expectation)
        {
            self.expected = expected
        }
    }
}
extension BSON.BinaryViewError:CustomStringConvertible
{
    public
    var description:String
    {
        "expected \(self.expected)"
    }
}
