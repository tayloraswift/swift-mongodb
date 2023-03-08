extension BSON
{
    /// A binary view was sliced from a malformed storage buffer.
    @frozen public
    struct BinaryViewError:Equatable, Error
    {
        @frozen public
        enum Expectation:Equatable
        {
            /// The input should have yielded a subtype byte.
            case subtype
            /// The input should have yielded a legacy subheader.
            case subheader
        }

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
extension BSON.BinaryViewError.Expectation:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .subtype:
            return "subtype (1 byte)"
        case .subheader:
            return "subheader (4 bytes)"
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
